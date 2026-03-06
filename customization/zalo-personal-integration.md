# Toàn Tập Tích Hợp Zalo Personal vào OpenFang

*(Tài liệu hướng dẫn cài đặt, cấu hình và vận hành Zalo bot không chính thức trong hệ sinh thái OpenFang)*

> **⚠️ Cảnh báo:** OpenFang dùng thư viện `zca-js` (unofficial) để giả lập Zalo Web — không phải Zalo OA API chính thức. Có thể dẫn đến nguy cơ bị khóa tài khoản Zalo nếu vi phạm chính sách chống spam. **Dùng tự chịu rủi ro.**

---

## 1. Zalo Bridge là gì?

OpenFang xây dựng tất cả channel adapter bằng Rust. Tuy nhiên, thư viện Zalo unofficial (`zca-js`) chỉ chạy được trên **Node.js**. Để giải quyết vấn đề này, giải pháp là tạo một **Zalo Bridge** — một microservice Node.js nhỏ chạy song song, đóng vai trò:

```
[ Zalo App/Server ]
        ↕  (zca-js + WebSocket)
[ Zalo Bridge (Node.js) :3100 ]
        ↕  (HTTP REST / WebSocket)
[ OpenFang Channel Adapter (Rust) ]
        ↕
[ OpenFang Agent / AI ]
```

**Cơ chế hoạt động:**
1. `Zalo Bridge (Node.js)` duy trì phiên đăng nhập với Zalo qua `zca-js`
2. Khi có tin nhắn đến, Bridge forward về OpenFang qua HTTP Webhook
3. Khi OpenFang cần gửi tin ra, nó gọi HTTP API của Bridge
4. Bridge map lại và gửi qua `zca-js` đến Zalo

---

## 2. Khả năng hỗ trợ của Zalo Bot

| Tính năng | Hỗ trợ | Ghi chú |
|-----------|--------|---------|
| Nhận tin nhắn 1-1 (DM) | ✅ | Mặc định được kích hoạt |
| Gửi tin nhắn văn bản | ✅ | Tự động cắt nhỏ nếu > 2000 ký tự |
| Nhận tin nhắn nhóm | ✅ | Cần cấu hình Group ID trong allowlist |
| Nhận diện @mention trong nhóm | ✅ | Khuyến nghị bật `requireMention: true` |
| Gửi ảnh / tệp | ✅ | Qua URL public hoặc upload |
| Nhận ảnh / tệp | 🔄 | Cần tích hợp thêm skill phân tích file |
| Typing indicator | ✅ | Gửi typing... trong khi xử lý |
| Push thông báo chủ động | ✅ | Bot tự nhắn (ví dụ: cron morning brief) |
| Voice message | ❌ | Chưa hỗ trợ |

---

## 3. Cấu trúc thư mục cần tạo

```
openfang/
├── zalo-bridge/           ← Tạo thư mục này (Node.js service)
│   ├── package.json
│   ├── index.js           ← Entry point
│   ├── session/           ← Lưu session Zalo (gitignore!)
│   └── .env               ← Chứa OPENFANG_WEBHOOK_URL
│
├── crates/
│   └── openfang-channels/
│       └── src/
│           └── zalo.rs    ← Thêm Rust adapter này
```

---

## 4. Bước 1 — Tạo Zalo Bridge (Node.js)

### 4.1 Khởi tạo dự án Node

```bash
cd /path/to/openfang
mkdir zalo-bridge && cd zalo-bridge
npm init -y
npm install zca-js express dotenv
```

### 4.2 Tạo file `zalo-bridge/index.js`

```javascript
const { Zalo, ZaloApiError } = require("zca-js");
const express = require("express");
require("dotenv").config();

const app = express();
app.use(express.json());

const OPENFANG_WEBHOOK_URL = process.env.OPENFANG_WEBHOOK_URL || "http://127.0.0.1:4200/api/channels/zalo/webhook";
const BRIDGE_PORT = parseInt(process.env.BRIDGE_PORT || "3100");
const ALLOWED_GROUP_IDS = (process.env.ALLOWED_GROUP_IDS || "").split(",").filter(Boolean);
const REQUIRE_MENTION  = process.env.REQUIRE_MENTION !== "false"; // default true

let zalo = new Zalo({ logging: false });
let api = null;

// ─── Khởi động & Đăng nhập ───────────────────────────────────
async function start() {
  try {
    api = await zalo.login({ qrPath: "./session/qr.png" });
    console.log("[Zalo Bridge] Đăng nhập thành công.");
    listenMessages();
  } catch (e) {
    console.error("[Zalo Bridge] Lỗi đăng nhập:", e.message);
    process.exit(1);
  }
}

// ─── Lắng nghe tin nhắn đến ──────────────────────────────────
function listenMessages() {
  api.listener.on("message", async (msg) => {
    try {
      const isGroup = !!msg.data.idTo; // group có idTo khác idFrom
      const groupId = isGroup ? String(msg.data.idTo) : null;
      const senderId = String(msg.data.uidFrom);
      const senderName = msg.data.dName || "Zalo User";
      const text = msg.data.content || "";

      // Group policy: chỉ xử lý group trong allowlist
      if (isGroup && ALLOWED_GROUP_IDS.length > 0 && !ALLOWED_GROUP_IDS.includes(groupId)) {
        return; // Bỏ qua nhóm không được phép
      }

      // Mention policy: trong nhóm phải @mention bot
      if (isGroup && REQUIRE_MENTION) {
        const mentions = msg.data.mentions || [];
        const botUid = api.getOwnId();
        if (!mentions.some(m => String(m.uid) === String(botUid))) {
          return; // Bot không được mention, bỏ qua
        }
      }

      // Forward đến OpenFang
      const payload = {
        platform: "zalo",
        message_id: String(msg.msgId),
        sender_id: isGroup ? groupId : senderId,
        sender_name: senderName,
        text: text,
        is_group: isGroup,
        group_id: groupId,
        timestamp: Date.now(),
      };

      await fetch(OPENFANG_WEBHOOK_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
    } catch (err) {
      console.error("[Zalo Bridge] Lỗi xử lý tin:", err.message);
    }
  });
  api.listener.start();
  console.log("[Zalo Bridge] Đang lắng nghe tin nhắn Zalo...");
}

// ─── API nhận lệnh gửi từ OpenFang ───────────────────────────
app.post("/send", async (req, res) => {
  const { to, text, is_group } = req.body;
  if (!to || !text) return res.status(400).json({ error: "Thiếu to hoặc text" });
  try {
    // Rate limit: delay 2 giây trước mỗi lần gửi
    await sleep(2000);
    if (is_group) {
      await api.sendMessage({ msg: text }, to, "Group");
    } else {
      await api.sendMessage({ msg: text }, to, "User");
    }
    res.json({ ok: true });
  } catch (e) {
    console.error("[Zalo Bridge] Lỗi gửi tin:", e.message);
    res.status(500).json({ error: e.message });
  }
});

// ─── Health check ─────────────────────────────────────────────
app.get("/health", (req, res) => {
  res.json({ status: "ok", logged_in: !!api });
});

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

app.listen(BRIDGE_PORT, () => {
  console.log(`[Zalo Bridge] HTTP API đang lắng nghe trên port ${BRIDGE_PORT}`);
  start();
});
```

### 4.3 Tạo file `zalo-bridge/.env`

```env
OPENFANG_WEBHOOK_URL=http://127.0.0.1:4200/api/channels/zalo/webhook
BRIDGE_PORT=3100
ALLOWED_GROUP_IDS=    # Để trống = chặn tất cả group, điền ID nhóm cách nhau bằng dấu phẩy
REQUIRE_MENTION=true  # true = phải @mention bot trong nhóm
```

---

## 5. Bước 2 — Đăng nhập Zalo lần đầu (Quét QR)

```bash
cd zalo-bridge
mkdir -p session
node index.js
```

Khi khởi động lần đầu, `zca-js` sẽ lưu mã QR vào `session/qr.png`.
Mở file ảnh này và quét bằng app **Zalo trên điện thoại** (tài khoản bot).

> **Lưu ý:** Sau khi quét thành công, session sẽ được lưu lại. Lần sau khởi động không cần quét lại.

---

## 6. Bước 3 — Cấu hình OpenFang nhận webhook

Thêm vào file `~/.openfang/config.toml`:

```toml
[channels.zalo]
bridge_url = "http://127.0.0.1:3100"
webhook_secret = ""          # Tùy chọn, thêm nếu muốn xác thực
default_agent = "assistant"  # Agent xử lý tin Zalo
```

---

## 7. Bước 4 — Chạy cả 2 dịch vụ

### Chạy Zalo Bridge

```bash
cd zalo-bridge
node index.js
# Kết quả bình thường:
# [Zalo Bridge] Đăng nhập thành công.
# [Zalo Bridge] Đang lắng nghe tin nhắn Zalo...
# [Zalo Bridge] HTTP API đang lắng nghe trên port 3100
```

### Restart OpenFang để nhận cấu hình Zalo mới

```bash
openfang restart
```

---

## 8. Lấy Group ID để đưa vào allowlist

Khi bot đã online trong một nhóm Zalo, nhắn lệnh:
```
/id
```
Bot sẽ phản hồi Group ID của nhóm đó. Copy ID và thêm vào `ALLOWED_GROUP_IDS` trong `.env`.

---

## 9. Cẩm nang an toàn — Tránh bị khóa tài khoản Zalo

| Hành vi nguy hiểm | Khuyến nghị |
|-------------------|-------------|
| Mở Zalo Web song song trên trình duyệt | **CHỈ 1 SESSION duy nhất.** Nếu muốn dùng Zalo Web, dừng Bridge trước: `Ctrl+C` |
| Spam tin nhắn hàng loạt | Không broadcast. Dùng nick phụ cho bot. Bật `requireMention: true` trong nhóm |
| Bot trống rỗng không hoạt động lâu | Thỉnh thoảng dùng điện thoại nhắn vài tin từ nick bot để giữ session |
| Gửi quá nhiều tin một lúc | Code đã có delay 2 giây mỗi tin. Không tắt delay này |

### Khôi phục khi bị khóa

1. **Đăng xuất ngay:** Dừng Bridge (`Ctrl+C`)
2. **Chờ 48 tiếng** nếu bị khóa tạm thời
3. **Liên hệ Zalo:** Gọi `1900 561 558` (phím 2) hoặc hỗ trợ trong App. Nói: *"Đăng nhập nhiều thiết bị IP khác nhau bị khóa an toàn"* — **tuyệt đối không đề cập bot/tool**
4. **Sau khi mở:** Hạn chế nhắn tin trong 7 ngày
5. **Đăng nhập lại:** Xóa `session/` cũ, chạy lại `node index.js` để lấy QR mới

---

## 10. Xử lý sự cố nhanh

| Triệu chứng | Nguyên nhân | Xử lý |
|-------------|-------------|-------|
| Bridge báo `Not authenticated` | Session Zalo hết hạn | Xóa `session/`, chạy lại `node index.js`, quét QR |
| Bot không phản hồi trong nhóm | Bot không được @mention | Gõ `@TênBot` trước câu hỏi |
| Lỗi `OPENFANG_WEBHOOK_URL connection refused` | OpenFang chưa chạy | `openfang start` trước khi khởi động Bridge |
| Bridge crash liên tục | Node.js lỗi hoặc `zca-js` hỏng | `npm install` lại trong thư mục `zalo-bridge/` |

### Restart Bridge nhanh

```bash
# Dừng
Ctrl+C

# Chạy lại
cd zalo-bridge && node index.js
```

---

## 11. Tự động khởi động Bridge cùng OpenFang

Thêm vào crontab để Bridge tự bật khi máy khởi động:

```bash
crontab -e
```

Thêm dòng:
```
@reboot cd /path/to/openfang/zalo-bridge && node index.js >> ~/.openfang/zalo-bridge.log 2>&1 &
```

---

*Tài liệu cập nhật lần cuối: 2026-03-06*
