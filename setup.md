# Hướng dẫn cài đặt OpenFang

OpenFang gói gọn mọi chức năng mạnh mẽ nhất trong một binary duy nhất viết bằng Rust (kích thước khoảng 32MB). Việc cài đặt vô cùng gọn nhẹ và an toàn.

## Cài đặt nhanh

Mở terminal và chạy dòng lệnh sau (hỗ trợ Linux / Unix / macOS):
```bash
curl -fsSL https://openfang.sh/install | sh
```

Khởi động platform:
```bash
openfang start
```

*Lưu ý cho Mac M4*: Phần mềm biên dịch bằng Rust native, chạy siêu mượt với tốc độ cực cao trên kiến trúc ARM (chỉ tốn ~40MB RAM ở trạng thái rỗi).

## Quản lý các "Hands"
OpenFang bao gồm nhiều Hands chạy xử lý song song và hoàn toàn tự trị. 
Để kích hoạt một Hand cụ thể, dùng cú pháp:
```bash
openfang hand spawn <hand-name>
# Hoặc truyền kèm tham số cụ thể:
openfang hand spawn collector --path /path/to/folder --cron "0 * * * *"
```

- **Kiểm tra trạng thái**: Để quản lý, pause hay resume Hand, chạy lệnh `openfang hand status`.
- **Custom Hand**: Tạo Hand theo nhu cầu bằng cách chỉnh định nghĩa ở file `HAND.toml`, bạn có thể chỉ định `tools` hoặc set prompt riêng và lưu truyền lên FangHub.

## Migration từ OpenClaw

Nếu bạn từng sử dụng `OpenClaw` (cài đặt khá to lớn qua Node.js: `npm i -g openclaw`, idle tốn khoảng gần 400MB và có thể rủi ro lộ data/plugins), bạn có thể dễ dàng chuyển đổi cấu hình qua hệ mới bằng tool lệnh hỗ trợ migration của OpenFang ("One-command migration").
Trên Mac Mini M4, nếu trước đó cài OpenClaw bạn có thể phải thông qua Rosetta, nhưng với OpenFang mọi thứ được hỗ trợ native.
