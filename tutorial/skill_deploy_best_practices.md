# Hướng dẫn: Bảo vệ Custom Skills khi Update OpenFang

Khi update OpenFang binary, thư mục `repo/` có thể bị ghi đè. File này hướng dẫn cách triển khai skill đúng cách để **không bao giờ mất dữ liệu sau update**.

---

## Nguyên tắc cốt lõi

```
~/.openfang/          ← USER DATA — không bao giờ bị update xóa
  ├── .env            ✅ An toàn
  ├── cron_jobs.json  ✅ An toàn
  ├── data/           ✅ An toàn (SQLite memory, reports)
  ├── skills/         ✅ An toàn (user skills — đây là nơi đúng để deploy)
  └── agents/         ✅ An toàn

repo/crates/openfang-skills/bundled/   ← SOURCE CODE — có thể bị ghi đè khi update
```

**Quy tắc:** Custom skill phải nằm trong `~/.openfang/skills/`, **không** đặt trong `repo/`.

---

## Deploy Skill đúng cách (bền vững)

### Bước 1 — Tạo thư mục skill trong user data

```bash
mkdir -p ~/.openfang/skills/<ten-skill>
```

### Bước 2 — Tạo `SKILL.toml`

```bash
cat > ~/.openfang/skills/<ten-skill>/SKILL.toml << 'EOF'
name = "<ten-skill>"
version = "1.0.0"
category = "<monitoring|automation|analysis|...>"
description = "<mô tả ngắn>"

tools = ["web_fetch", "memory_store", "memory_recall", "file_write"]
# Chỉ khai báo tools thực sự cần dùng
# Tránh khai báo shell_exec trừ khi thực sự cần (yêu cầu approval)

system_prompt = """
<Toàn bộ instructions cho agent ở đây>
"""
EOF
```

### Bước 3 — Tạo `SKILL.md` (documentation)

```bash
cat > ~/.openfang/skills/<ten-skill>/SKILL.md << 'EOF'
# <Tên Skill>

<Mô tả skill, cách dùng, config>
EOF
```

### Bước 4 — Hardcode credentials vào cron job, không dựa vào SKILL.toml

Khi thêm cron job vào `cron_jobs.json`, **nhúng toàn bộ instructions vào `message`**:

```json
{
  "action": {
    "kind": "agent_turn",
    "message": "Toàn bộ instructions ở đây — không tham chiếu file ngoài",
    "timeout_secs": 120
  }
}
```

> ✅ Cron job sẽ hoạt động ngay cả khi SKILL.toml bị mất.

---

## Migrate skill từ `repo/bundled/` sang `~/.openfang/skills/`

Nếu đã deploy nhầm vào `repo/bundled/`, chạy:

```bash
SKILL_NAME="<ten-skill>"

# Copy sang đúng vị trí
mkdir -p ~/.openfang/skills/$SKILL_NAME
cp repo/crates/openfang-skills/bundled/$SKILL_NAME/* \
   ~/.openfang/skills/$SKILL_NAME/

# Verify
ls -la ~/.openfang/skills/$SKILL_NAME/
```

---

## Checklist trước khi update OpenFang

```bash
# 1. Kiểm tra vị trí skill — phải nằm trong ~/.openfang/skills/
ls ~/.openfang/skills/

# 2. Kiểm tra cron jobs còn nguyên
openfang cron list

# 3. Backup toàn bộ user data (phòng hờ)
cp -r ~/.openfang ~/.openfang_backup_$(date +%Y%m%d)

# 4. Update binary
curl -fsSL https://openfang.sh/install | sh

# 5. Restart daemon
openfang stop && openfang start

# 6. Kiểm tra cron jobs sau update
openfang cron list

# 7. Test gửi alert Telegram (nếu có)
curl -s -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
  -d "chat_id=<CHAT_ID>&text=✅ Post-update test OK"
```

---

## Tóm tắt: Đặt file đúng chỗ

| File | Đặt ở đâu | Lý do |
|------|-----------|-------|
| `SKILL.toml` | `~/.openfang/skills/<name>/` | Không bị overwrite |
| `SKILL.md` | `~/.openfang/skills/<name>/` | Không bị overwrite |
| Cron job | `~/.openfang/cron_jobs.json` | User data, luôn safe |
| Credentials | `~/.openfang/.env` | User data, luôn safe |
| Reports/output | `~/.openfang/data/` | User data, luôn safe |
