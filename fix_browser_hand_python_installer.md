# Khắc phục lỗi "Python 3 must be installed" của Browser Hand

**Mô tả:** Mặc dù máy tính (đặc biệt là macOS cài Python qua Homebrew) có cài đặt `python3` và đã cài đủ Playwright, màn hình thiết lập Browser Hand của OpenFang thỉnh thoảng sẽ vẫn báo tick vàng X ở mục **Dependencies >> Python 3 must be installed**.

**Nguyên nhân gốc:** OpenFang Core Agent sử dụng cơ chế kiểm tra `check_value` được cấu hình cứng trong File thiết lập của plugin `HAND.toml`. Từ khóa ban đầu được tìm là `python` thay vì `python3`. Điều này dẫn đến lệnh check thất bại trên MacOS vì bản Mac mặc định không phân luồng lệnh `python` tới nhánh `python3` ở `/opt/homebrew/bin/`.

## Cách giải quyết

Để hệ thống OpenFang có thể nhận diện đúng Python 3 (path gốc `/opt/homebrew/bin/python3`) trên macOS, anh có 2 giải pháp hoàn toàn an toàn:

### Cách 1: Fix triệt để thông qua Config core của OpenFang (Cách khuyên dùng)
Trực tiếp sửa file biến định nghĩa của Hand này thành `python3`.

1. Từ thư mục Repo của ứng dụng, hãy tìm file config:
   `crates/openfang-hands/bundled/browser/HAND.toml`
2. Tìm đến mục Require thiết lập:
   ```toml
   [[requires]]
   key = "python3"
   label = "Python 3 must be installed"
   requirement_type = "binary"
   check_value = "python"
   ```
3. Đổi biến `check_value` thành `"python3"`:
   ```toml
   ...
   check_value = "python3"
   ...
   ```
4. Restart lại tiến trình OpenFang: `openfang stop && openfang start`. Hệ thống sẽ tức khắc lên dấu ✅ Xanh lá cho Python.

### Cách 2: Tạo Symlink hệ thống để dẫn lệnh "python" trở về "python3" 
Vì macOS thường không có lệnh `python`, ta có thể tạo 1 alias lệnh cho máy tính ở cấp core hệ thống:

Mở iTerm gõ lệnh:
```bash
sudo ln -sf $(which python3) /usr/local/bin/python
```
Sau đó khởi động lại OpenFang. Phân luồng openfang check bằng lệnh `python` sẽ tự động chuyển hướng về bash chuẩn của `python3` trên MacOS.
