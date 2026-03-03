# OpenFang Update Monitor — Hướng dẫn triển khai

Monitor tự động kiểm tra GitHub Releases của OpenFang và gửi alert Telegram khi có version mới. Chạy 8:00 AM hàng ngày.

---

## Kiến trúc

```
8:00 AM (cron_jobs.json)
  └─→ Agent "assistant" nhận prompt
        ├─ memory_recall: lấy version cũ + ETag
        ├─ web_fetch: GitHub API (với ETag cache → 304 = skip)
        ├─ So sánh version
        └─ Nếu mới: web_fetch POST Telegram + memory_store + file_write report
```

**Không dùng shell_exec** — toàn bộ logic chạy qua `web_fetch`, `memory_store`, `memory_recall`, `file_write`.

---

## Bước 1 — Tạo Telegram Bot

```
1. Nhắn @BotFather trên Telegram → /newbot
2. Đặt tên bot → lấy TOKEN (dạng: 1234567890:ABCdef...)
3. Thêm bot vào group/channel hoặc nhắn trực tiếp
4. Nhắn bot ít nhất 1 tin để tạo update
5. Lấy chat_id:
   curl -s "https://api.telegram.org/bot<TOKEN>/getUpdates" \
     | python3 -c "
       import sys, json
       data = json.load(sys.stdin)
       for u in data.get('result', []):
           chat = u.get('message', {}).get('chat', {})
           print('chat_id:', chat.get('id'), '| type:', chat.get('type'), '| name:', chat.get('first_name', chat.get('title', '')))
     "
```

---

## Bước 2 — Cấu hình .env

Thêm vào `~/.openfang/.env`:

```bash
TELEGRAM_BOT_TOKEN=<TOKEN_TU_BOTFATHER>
TELEGRAM_CHAT_ID=<CHAT_ID_TU_BUOC_TREN>
```

> **Lưu ý:** `CHAT_ID` của private chat là số dương, của group là số âm.

---

## Bước 3 — Tạo Skill bundled

Tạo 2 files trong repo:

### `repo/crates/openfang-skills/bundled/openfang-update-monitor/SKILL.toml`

```toml
name = "openfang-update-monitor"
version = "1.0.0"
category = "monitoring"
description = "Giám sát GitHub Releases của OpenFang — alert Telegram khi có version mới"

tools = ["web_fetch", "memory_store", "memory_recall", "file_write"]

[config]
github_api_url = "https://api.github.com/repos/RightNow-AI/openfang/releases/latest"
memory_key_version = "openfang_last_known_version"
memory_key_etag    = "openfang_releases_etag"

system_prompt = """
Bạn là agent giám sát OpenFang Release. QUAN TRỌNG: Chỉ dùng web_fetch, memory_store, memory_recall, file_write. TUYỆT ĐỐI KHÔNG dùng shell_exec.

Buoc 1: memory_recall key=openfang_last_known_version → LAST_VER
Buoc 2: memory_recall key=openfang_releases_etag → LAST_ETAG
Buoc 3: web_fetch url=https://api.github.com/repos/RightNow-AI/openfang/releases/latest headers={Accept: application/vnd.github+json, If-None-Match: {LAST_ETAG}, User-Agent: OpenFang-Monitor/1.0}
  - HTTP 304 → dừng, không có gì mới
  - HTTP 200 → lưu ETag mới, tiếp tục
Buoc 4: Lấy tag_name, html_url, published_at, 5 dòng đầu body
Buoc 5: Nếu tag_name == LAST_VER → dừng
Buoc 6: Nếu version mới:
  a) web_fetch method=POST url=https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage headers={Content-Type: application/json} body={chat_id: {TELEGRAM_CHAT_ID}, parse_mode: Markdown, text: "🚀 *OpenFang Update!*\n\n📦 Version: `{tag_name}`\n📅 {ngay}\n✅ Stable\n\n[Xem release]({html_url})"}
  b) memory_store key=openfang_last_known_version value={tag_name}
  c) memory_store key=openfang_releases_etag value={etag_moi}
  d) file_write path=~/.openfang/data/openfang-updates/update-{tag_name}.md
Buoc 7: Báo cáo kết quả ngắn gọn.
"""
```

### `repo/crates/openfang-skills/bundled/openfang-update-monitor/SKILL.md`

```markdown
# 🚀 OpenFang Update Monitor Skill

Monitor GitHub Releases của OpenFang, alert Telegram khi có version mới.

## Memory keys
- `openfang_last_known_version` — version đã biết
- `openfang_releases_etag` — ETag HTTP cache

## Telegram setup
Đặt trong `~/.openfang/.env`:
TELEGRAM_BOT_TOKEN=<token>
TELEGRAM_CHAT_ID=<chat_id>

## Kích hoạt thủ công
openfang message <AGENT_ID> "Chay skill openfang-update-monitor..."
```

---

## Bước 4 — Lấy Agent ID

```bash
sqlite3 ~/.openfang/data/openfang.db \
  "SELECT id, name FROM agents WHERE name='assistant';"
# Output: <UUID>|assistant
```

Ghi lại `<UUID>` để dùng ở Bước 5.

---

## Bước 5 — Thêm Cron Job vào `cron_jobs.json`

Chạy script Python này (sửa `AGENT_ID` và credentials trong message):

```python
import json, uuid
from datetime import datetime, timezone

AGENT_ID = "<UUID_TU_BUOC_4>"
BOT_TOKEN = "<TELEGRAM_BOT_TOKEN>"
CHAT_ID = "<TELEGRAM_CHAT_ID>"

cron_file = "/Users/<username>/.openfang/cron_jobs.json"

with open(cron_file, 'r') as f:
    jobs = json.load(f)

message = f"""Chay skill openfang-update-monitor. Chi dung web_fetch, khong dung shell_exec.
Buoc 1: memory_recall key=openfang_releases_etag va key=openfang_last_known_version.
Buoc 2: web_fetch url=https://api.github.com/repos/RightNow-AI/openfang/releases/latest headers=[Accept=application/vnd.github+json, If-None-Match=<etag_cu>].
Buoc 3: Neu HTTP 304: dung lai.
Buoc 4: Lay tag_name, html_url, published_at, 5 dong dau body.
Buoc 5: Neu tag_name == last_version: dung lai.
Buoc 6: Neu moi: web_fetch POST url=https://api.telegram.org/bot{BOT_TOKEN}/sendMessage body JSON chat_id={CHAT_ID} parse_mode=Markdown text=<alert dep>. memory_store key=openfang_last_known_version. memory_store key=openfang_releases_etag. file_write report.
Buoc 7: Bao cao."""

new_job = {
    "job": {
        "id": str(uuid.uuid4()),
        "agent_id": AGENT_ID,
        "name": "openfang-update-monitor",
        "enabled": True,
        "schedule": {
            "kind": "cron",
            "expr": "0 8 * * *",
            "tz": "Asia/Ho_Chi_Minh"
        },
        "action": {
            "kind": "agent_turn",
            "message": message,
            "model_override": None,
            "timeout_secs": 120
        },
        "delivery": {
            "kind": "channel",
            "channel": "telegram",
            "to": "default"
        },
        "created_at": datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z'),
        "last_run": None,
        "next_run": None
    },
    "one_shot": False,
    "last_status": None,
    "consecutive_errors": 0
}

jobs.append(new_job)

with open(cron_file, 'w') as f:
    json.dump(jobs, f, indent=2, ensure_ascii=False)

print("OK — job id:", new_job['job']['id'])
```

---

## Bước 6 — Verify và Test

```bash
# 1. Start daemon (nếu chưa chạy)
openfang start

# 2. Kiểm tra cron job đã được nhận
openfang cron list
# → Phải thấy "openfang-update-monitor" với enabled: true

# 3. Test gửi Telegram (curl trực tiếp)
curl -s -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": <CHAT_ID>,
    "parse_mode": "Markdown",
    "text": "✅ *OpenFang Monitor — Test OK!*\n\nSẽ tự động chạy lúc 8AM."
  }' | python3 -c "import sys,json; d=json.load(sys.stdin); print('OK' if d.get('ok') else 'LỖI:', d)"

# 4. Test trigger thủ công (agent phải đang chạy)
openfang message <AGENT_ID> "Chay test Telegram: web_fetch POST https://api.telegram.org/bot<TOKEN>/sendMessage body JSON {chat_id:<CHAT_ID>, parse_mode:Markdown, text:'Test alert'}. Chi dung web_fetch, khong dung shell_exec."

# 5. Lưu version baseline vào memory (lần đầu deploy)
openfang message <AGENT_ID> "memory_store key=openfang_last_known_version value=<CURRENT_VERSION>"
```

---

## Bước 7 — Lần đầu chạy: Lưu baseline version

Trước khi cron tự động chạy, cần lưu version hiện tại vào memory:

```bash
# Lấy version hiện tại
curl -s "https://api.github.com/repos/RightNow-AI/openfang/releases/latest" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('Version:', d.get('tag_name'))"

# Lưu vào memory
openfang message <AGENT_ID> "memory_store key=openfang_last_known_version value=<VERSION_VUA_LAY>"
```

> **Nếu không lưu baseline**, lần đầu cron chạy sẽ coi mọi version là "mới" và gửi alert.

---

## Troubleshooting

| Vấn đề | Nguyên nhân | Giải pháp |
|--------|-------------|-----------|
| Không thấy cron job | Daemon chưa chạy | `openfang start` |
| Agent dùng shell_exec | LLM "sáng tạo" | Nhấn mạnh "KHONG dung shell_exec" trong message |
| Telegram không nhận | CHAT_ID sai | Chạy `getUpdates` để lấy lại chat_id |
| GitHub 403 rate limit | Quá 60 req/giờ | Thêm `If-None-Match` ETag header, hoặc tạo GitHub token |
| Approval request blocked | `shell_exec` trong capabilities | Add `"web"` vào tool whitelist hoặc tránh prompt gọi shell |

---

## Files trong repo

```
repo/crates/openfang-skills/bundled/openfang-update-monitor/
├── SKILL.toml    # Manifest + system_prompt
└── SKILL.md      # Documentation

docs/
├── openfang_update_monitor_setup.md   # File này
└── openfang_update_monitor_cron.toml  # Cron config tham khảo
```

---

## Checklist deploy trên máy mới

- [ ] Tạo Telegram bot → lấy TOKEN
- [ ] Nhắn bot → lấy CHAT_ID
- [ ] Thêm `TELEGRAM_BOT_TOKEN` + `TELEGRAM_CHAT_ID` vào `~/.openfang/.env`
- [ ] Copy 2 files skill vào `bundled/openfang-update-monitor/`
- [ ] Lấy `agent_id` của assistant từ SQLite
- [ ] Chạy Python script → thêm vào `cron_jobs.json`
- [ ] `openfang start` → `openfang cron list` → xác nhận job enabled
- [ ] Test curl gửi Telegram thành công (`ok: true`)
- [ ] Lưu baseline version vào memory
- [ ] Chờ 8AM ngày hôm sau → kiểm tra không có alert giả
