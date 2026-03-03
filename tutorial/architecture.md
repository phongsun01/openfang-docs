# Kiến trúc OpenFang

OpenFang được thiết kế với ưu tiên hàng đầu về hiệu suất, bảo mật và khả năng mở rộng cho các agent AI tự trị 24/7.

## Tổng quan Stack
- **Ngôn ngữ Core**: Rust (khoảng 137k dòng code), biên dịch thành một file binary duy nhất siêu nhẹ (~32MB).
- **Hiệu năng**: Thời gian cold start chỉ mất 180ms, tiêu thụ bộ nhớ khi rỗi (idle) khoảng 40MB. Rất tối ưu khi chạy trên các thiết bị như Mac Mini M4.

## Các thành phần chính
1. **Hands (Agent tự trị)**: Các module agent hoạt động độc lập (như Clip, Lead, Browser, Researcher, Collector, Predictor). Chúng phục vụ các nhiệm vụ chuyên biệt, tự động chạy theo lịch hoạt động, theo dõi sát sao dữ liệu và tự động hóa những tiến trình kinh doanh phức tạp.
2. **Channel Adapters**: Cung cấp giao tiếp hai chiều với 40 nền tảng nhắn tin/mạng xã hội (Telegram, WhatsApp, Slack, Discord, email, terminal...).
3. **Tools & Providers**: Đi kèm 38 internal tools phục vụ scraping, system info, HTTP... và có khả năng định tuyến (routing) prompt qua 27 nhà cung cấp LLM khác nhau.
4. **Workflow Engine**: Hỗ trợ trigger thông qua cron job, cho phép tự động hóa liên tục đa bước và kết nối linh hoạt giữa các "Hand".
5. **Knowledge Graph (KG)**: Chạy persistent KG cho phép liên kết entity, phục vụ các câu query nhanh bằng LLM.

## Bảo mật nhiều lớp
Khác với các hệ thống Node.js như OpenClaw, OpenFang bảo vệ người dùng và dữ liệu cực kì triệt để thông qua 16 lớp bảo mật:
1. **WASM Sandbox**: Cô lập hoàn toàn môi trường thực thi của các plugins và tools bên ngoài.
2. **Merkle Audit Trail**: Lưu trữ log không thể thay đổi, đảm bảo audibility rành mạch từ hệ thống.
3. **Taint Tracking**: Kiểm soát luồng di chuyển của dữ liệu nhạy cảm theo thời gian thực.
4. **Secrets Store**: Các cấu hình như API keys hay credentials được mã hóa và lưu trữ an toàn trong SQLite của hệ thống thay vì lộ trên text file.
