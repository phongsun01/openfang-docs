# OpenFang Documentation

Welcome to the official documentation for OpenFang.

OpenFang là một hệ điều hành mã nguồn mở dành cho các agent AI tự trị, được xây dựng hoàn toàn bằng Rust và phát hành dưới giấy phép MIT. Dự án tập trung vào các "Hands" tự động chạy theo lịch trình, cung cấp môi trường bền vững cho agent hoạt động độc lập (được phát triển bởi RightNow-AI, từ v0.1.x, tháng 2/2026).

## Tính năng nổi bật
- **7 Hands tự trị**: Researcher (nghiên cứu sâu), Lead (tìm lead), Clip (cắt video), Browser (tự động web), Collector (thu thập OSINT), Predictor (dự báo),...
- **Kết nối mạnh mẽ**: Hỗ trợ 40 kênh giao tiếp (Telegram, Discord, Slack,...), 38 tools và 27 LLM providers.
- **Bảo mật tối đa**: 16 lớp bảo vệ (bao gồm WASM sandbox, Merkle audit trail, taint tracking,...).
- **Hiệu suất cao**: Viết bằng Rust, siêu nhẹ (idle ~40MB), khởi động cực nhanh (cold start 180ms).

## So sánh nhanh với OpenClaw
OpenClaw là giải pháp cũ bằng Node.js (cài đặt rất nặng, idle tốn ~394MB, cold start chậm ~5980ms) dựa vào việc user phải prompt và tồn tại nhiều lỗ hổng ở việc expose instance/plugin. Trong khi đó, **OpenFang** chạy schedule 24/7, tự động build knowledge graph, cực kì bảo mật và hoàn toàn nhẹ (cài đặt siêu nhanh qua một file binary ~32MB).

## Mục lục
- [Kiến trúc (Architecture)](architecture.md)
- [Cài đặt (Setup Guide)](setup.md)
- [Hướng dẫn sử dụng (User Guide)](user_guide.md)
- [Tích hợp API & OAuth (API Reference)](api.md)
