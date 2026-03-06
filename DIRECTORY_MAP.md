# Bản đồ Cấu trúc Kho tài liệu OpenFang (openfang-docs)

Kho lưu trữ này chứa toàn bộ tài liệu hướng dẫn, quy trình vận hành và các bản vá tùy chỉnh cho hệ thống OpenFang của bạn. Dưới đây là giải thích về cấu trúc các thư mục và tập tin chính:

## 📂 Thư mục chính

### 🛠 `customization/`
Chứa các bản vá (patch) và cấu hình cá nhân hóa được tạo riêng cho hệ thống của bạn.
- `fix_alibaba_rate_limit.md`: Script quan trọng để gỡ bỏ giới hạn 1$/giờ của OpenFang khi dùng gói Alibaba.
- `alibaba-coding-plan.md`: Hướng dẫn tích hợp gói coding Alibaba.
- `9router_integration.md`: Hướng dẫn thêm các nhà cung cấp AI tùy chỉnh qua 9Router.
- `muasamcong_workflows.md`: Các quy trình theo dõi đấu thầu tự động.
- `muasamcong_cron.toml`, `openfang_update_monitor_cron.toml`: Các file cấu hình chạy tự động (Crontab).
- `fix_browser_hand_python_installer.md`: Sửa lỗi cài đặt môi trường cho Browser Hand.

### 📚 `tutorial/`
Chứa các tài liệu hướng dẫn cơ bản và kiến trúc hệ thống.
- `openfang_overview.md`: Tổng quan về hệ điều hành Agent OpenFang.
- `setup.md` & `upgrade-macos.md`: Hướng dẫn cài đặt và nâng cấp.
- `user_guide.md` & `hands_cli_guide.md`: Hướng dẫn sử dụng các kỹ năng tự động (Hands).
- `architecture.md`: Giải thích cấu trúc kỹ thuật bên trong.
- `api.md`: Tài liệu kỹ thuật dành cho lập trình viên.
- `zalo-personal-integration.md`: Quy trình chi tiết tích hợp Zalo Personal qua Bridge Node.js.

### ⚡ `scripts/`
Chứa các công cụ tự động hóa để duy trì hệ thống.
- `apply_customizations.py`: Script quan trọng nhất để **tự động nạp lại** các tùy chỉnh UI và Provider sau khi bạn cập nhật phiên bản OpenFang mới từ Github.
- `post_update.sh`: Script chạy nhanh sau cập nhật để khôi phục trạng thái ổn định.
- `openfang_watchdog.sh`: "Chó săn" giám sát Bot, tự động khởi động lại nếu Bot treo.

## 📄 Tập tin gốc (Root)

- `CHANGELOG.md`: Nhật ký thay đổi chi tiết qua từng phiên bản tài liệu.
- `VERSION`: Phiên bản hiện tại của kho tài liệu (vd: 1.3.4).
- `README.md`: Giới thiệu ngắn gọn về kho tài liệu.

---
*Lưu ý: Luôn ưu tiên tham khảo các file trong `customization/` trước khi thực hiện các thay đổi lớn lên hệ thống.*
