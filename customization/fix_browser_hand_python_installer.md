# Cẩm nang Khắc phục lỗi "Python 3 must be installed" của Browser Hand trên OpenFang

**Trường hợp gặp lỗi:** Máy (ví dụ: macOS) đã cài đặt `python3` qua luồng trung gian (như Homebrew) và đã setup đủ Playwright. Tuy nhiên ở màn hình thiết lập Browser Hand của OpenFang liên tục báo tích vàng `X` cảnh báo thiếu Python 3, dù ấn Refresh hay Restart daemon đều không hết.

**Nguyên nhân kĩ thuật gốc:** Tính năng Browser Hand của OpenFang có một file tùy chỉnh cứng là `HAND.toml`. Trong file này biến yêu cầu hệ thống `check_value` mặc định được hardcode là `python`. Vì macOS không phân quyền cho command gốc `python` gọi thẳng đến nhánh `python3`, nên chương trình check validation trên Rust OS báo Fail (Command not found). Quan trọng nhất là file `HAND.toml` này được tích hợp tĩnh ở mức "nhúng trực tiếp" vào binary (`rust-embed`) khi cargo được biên dịch, dẫn đến việc chỉ sửa text file này thôi chưa làm OpenFang thay đổi trạng thái nếu không biên dịch lại.

---

## 🛠️ Quy trình 3 bước khắc phục lỗi tận gốc

Phương pháp này sẽ sửa trực tiếp cấu trúc mã nguồn lõi của Browser Hand để hệ thống tự động tìm đúng alias của python3.

### Bước 1: Trỏ lệnh nhận diện về đúng path Python3
Từ thư mục mã nguồn gốc của OpenFang (Folder có chứa các Crate), mở cấu hình Browser Hand tại vị trí:
`crates/openfang-hands/bundled/browser/HAND.toml`

Kéo xuống phần Require, nội dung cũ của nó sẽ có dạng:
```toml
[[requires]]
key = "python3"
label = "Python 3 must be installed"
requirement_type = "binary"
check_value = "python"
```

Tiến hành đổi giá trị của `check_value` biến thành `"python3"`:
```toml
[[requires]]
key = "python3"
label = "Python 3 must be installed"
requirement_type = "binary"
check_value = "python3" # Đổi mục này
```

### Bước 2: Biên dịch lại Module Hands và Binary OpenFang
Vì `HAND.toml` là file tĩnh nhúng khi compile, bạn phải chạy lệnh build lại Cargo của module đó để hệ thống ghi đè cấu hình mới vào Core của OpenFang.

Mở Terminal và gõ:
```bash
# Touch file code để break cache build của Cargo
touch crates/openfang-hands/src/lib.rs

# Biên dịch lại đích danh các openfang packet liên quan
cargo build --release -p openfang-hands && cargo build --release --bin openfang -j 6
```

### Bước 3: Copy thay thế file cài đặt và Restart
Tiến hành ghi đè file binary mới khởi tạo vào thư mục bin của hệ thống và reload:

```bash
# Dừng OpenFang cũ
openfang stop

# Copy file thực thi
cp target/release/openfang ~/.cargo/bin/openfang

# (Tùy chọn cho Linux khác, path cũ có thể khác)

# Khởi động lại
openfang start
```

Ngay sau khi daemon chạy lên, bạn hãy mở Dashboard và vào màn hình cài đặt Browser Hand. Mục Dependency của Python 3 sẽ lập tức hiển thị check xanh ✅.

---

### Phương pháp phụ 2: Bypass mà không cần Compile lại (Mẹo Symlink)
Trong một số môi trường mà bạn vội và không muốn Build lại file Binary khá nặng nề, bạn có thể can thiệp thẳng vào hệ điều hành OS để dẫn lệnh `python` về đúng `python3`:

Mở Terminal gốc của hệ điều hành, cấp quyền alias trực tiếp:
```bash
sudo ln -sf $(which python3) /usr/local/bin/python
```
Sau đó chỉ cần khởi động lại `openfang stop && openfang start` là xong. Bộ openfang check lệnh `python` sẽ tự chui vào Bash của python3.
