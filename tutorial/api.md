# Tích hợp API & MCP Reference

Để cấp quyền cho OpenFang gọi ra bên ngoài, bạn có thể thiết lập 38 built-in tools (HTTP client, MCP Protocol,...). Các thông tin được cấu hình trong `config.toml` (thường ở `~/.openfang/config.toml` hoặc dưới dạng Docker env) hoặc ngay trong `HAND.toml` của chính các Hands đó. OpenFang sử dụng "secrets store" để lưu log an toàn.

## 1. Tích hợp API đơn giản (HTTP/REST)

### Quản lý Secrets
```bash
openfang secrets set EXAMPLE_API_KEY=yourkey
```
*(Secrets được mã hóa và lưu siêu an toàn trong SQLite).*

### Cấu hình `config.toml`
Biến `{{ secrets... }}` sẽ tự động được inject vào requests:

```toml
[tools.http]
base_url = "https://api.example.com"
api_key = "{{ secrets.EXAMPLE_API_KEY }}"
headers = { Authorization = "Bearer {{ secrets.TOKEN }}" }
```

### Cách sử dụng nội bộ
LLM có thể tự động gọi `http_get("/endpoint")` bằng công cụ tương ứng đã setup. Thậm chí OpenFang tự động expose OpenAI-compatible API tại: `localhost:4200/v1/chat/completions`, bạn có thể tận dụng SDK OpenAI chuẩn để trỏ vào OpenFang.

## 2. Tích hợp OAuth2 (Google, Slack,...)

Bạn có thể tự custom tool tích hợp OAuth2 chuyên sâu bằng cấu hình `HAND.toml`:

```toml
[[tools]]
name = "oauth_google"
type = "oauth2"
client_id = "{{ secrets.GOOGLE_CLIENT_ID }}"
client_secret = "{{ secrets.GOOGLE_CLIENT_SECRET }}"
scopes = ["https://www.googleapis.com/auth/drive"]
token_url = "https://oauth2.googleapis.com/token"
```

**Luồng hoạt động (Flow):**
1. Khi LLM trigger tool này, OpenFang quản lý handle redirect/auth.
2. Nhận và lưu lại an toàn Refresh Token.
3. Auto renew khi rớt session.

Với các channels hỗ trợ built-in (Slack/Telegram), workflow cực kỳ nhanh gọn qua trình duyệt:
```bash
openfang channel add slack --oauth
```

## 3. Tích hợp MCP & Agent-to-Agent (A2A)
Để thiết lập các External MCP server (ví dụ connect giữa các hệ sinh thái Agents), hãy sử dụng auth HMAC:
```bash
openfang mcp connect --url https://external-mcp.com --key your_hmac
```

**Ví dụ thực tế**:
Tích hợp API ứng dụng y tế (`MedicalDocBot`). Cấu hình Tool HTTP gọi tới endpoint riêng để phân loại bệnh án tự động, sau đó test ngay trên Hand:
```bash
openfang chat researcher
# Người dùng gõ: "Gọi API so sánh thiết bị y tế"
```
Hệ thống sẽ tự load tool và fetch cấu hình HTTP gọi backend xử lý nghiệp vụ! Nhớ chạy `openfang restart` trước khi gọi để load file config mới nhất.
