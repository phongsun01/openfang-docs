# Kế hoạch Cập nhật OpenFang & Tái áp dụng Customization

Bản gốc của [RightNow-AI/openfang](https://github.com/RightNow-AI/openfang) vừa release **v0.3.5**. Hiện tại source code trong thư mục `repo/` của anh đang ở bản thấp hơn (0.2.x). 
Vì anh đã có các cấu hình customize (9router, UI Add/Edit Button, Alibaba Coding plan), dưới đây là Plan chi tiết để anh dễ dàng cập nhật hệ thống mà không lo mất các tuỳ chỉnh này.

## Quy trình 3 Bước cập nhật

### BƯỚC 1: Lấy bản cập nhật (v0.3.5) từ chính chủ về thư mục `repo/`
Thao tác này chỉ cần thực hiện việc git pull hoặc đối chiếu lại source. Do anh chỉ clone mã nguồn về laptop, anh có thể vào thư mục `repo/` và dọn code cũ để lấy code mới:

```bash
cd /Users/xitrum/Library/CloudStorage/Box-Box/Tai\ lieu\ -\ Phong/Study2/Antigravity/Openfang/repo

# Huỷ bỏ các đoạn code modify tạm thời của phiên bản hiện tại để git pull không bị lỗi Merge Conflict
git restore crates/

# Khéo mã nguồn mới nhất của OpenFang
git pull origin main

# (Tùy chọn) Kiểm tra xem phiên bản mới thực sự đã về chưa
grep "version =" Cargo.toml
```

### BƯỚC 2: Chạy công cụ tự khôi phục các tính năng Custom
Ở bản document version 1.3.1 em vừa hỗ trợ, anh đã có script tiện ích `post_update.sh`. Script này sẽ tìm các mục tiêu trong version mới và tiêm mã 9router/Edit button vào đúng chỗ an toàn dựa trên Regex.

Từ thư mục gốc **OpenFang/** (nơi chứa thư mục `repo/`):

```bash
cd "repo/"

# Cấp quyền thực thi và chạy
chmod +x scripts/post_update.sh
./scripts/post_update.sh
```
*Màn hình sẽ báo "Thêm NINEROUTER_BASE_URL", "Map 9Router Defaults", "Thêm UI nút Edit...", v.v là thành công.*

### BƯỚC 3: Compile & Thay thế Core OpenFang  
Sau khi có source v0.3.5 đã được nhúng tính năng Custom, anh hãy build lại ứng dụng.

```bash
# Build binary
cargo build --release

# Thay thế binary OpenFang cũ trong path của Mac (nếu anh đang đặt ở ~/.cargo/bin/) bằng binary v0.3.5
cp target/release/openfang ~/.cargo/bin/openfang

# Khởi động lại dịch vụ Openfang (nếu chạy daemon)
openfang restart
```

---

> 📝 **Ghi chú về Alibaba Coding Plan:** 
Config của tính năng này (cấu hình agent) đã nằm ở file `/Users/xitrum/.openfang/config.toml` và các token nằm tại `~/.openfang/.env`, là không gian người dùng, vì vậy nó hoàn toàn VÔ HÌNH với source code gốc. Hệ thống OpenFang v0.3.5 sẽ tự động nhận diện lại config này sau khi được bật lên mà không cần anh phải làm thêm gì.
