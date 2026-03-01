# Hướng dẫn sử dụng OpenFang

Với 7 Hands cơ bản (Agent) và workflow kích hoạt tự động 24/7 linh hoạt, OpenFang đáp ứng hầu hết quy trình nghiệp vụ IT, Cybersecurity cũng như Sale tự động.

## 1. Giới thiệu các "Hands" phục vụ tự trị
- **Clip**: Tái tạo video dài thành clip ngắn tự động; có sinh caption, thumbnail viral và voice-over AI. Auto publish lên Telegram, WhatsApp.
- **Lead**: Tự động scrape web/list doanh nghiệp để tìm leads, enrich chi tiết, chấm điểm đánh giá (0-100 độ fit ICP) định kỳ, trả về file CSV/JSON lúc thu hoạch.
- **Browser**: Workflow trình duyệt tự động (tự tìm button, click, điền params), qua cổng CAPTCHA thông minh hỗ trợ gate approval mua hàng.
- **Researcher**: Agents tự tổng hợp nghiên cứu tình hình/đối tượng theo dõi qua các kênh, viết báo cáo định kì chuyên sâu.
- **Collector**: Monitor mạnh mẽ cấu hình tên miền (DNS/SSL), check OSINT.
- **Predictor**: Lập mô phỏng dựa trên data lịch sử để gợi ý cho kinh doanh, phân bổ tài nguyên.

## 2. Monitor Web & Dịch vụ (Cybersecurity & IT)
Thu thập OSINT, giám sát rò rỉ Dark Web, hoặc chỉ đơn thuần theo dõi Uptime server sử dụng:
1. `Collector`: Kích hoạt via `openfang hand activate collector` 
2. Set trong `config.toml` giá trị xpath hoặc keyword theo dõi.
Phát hiện lỗ hổng hay trigger scan đều có thể tạo tự động báo cáo qua chat.

## 3. Quản lý, phân loại và tìm kiếm tài liệu tiên tiến
Tận dụng **Collector** rà quét qua folder local.
```bash
openfang hand spawn collector --path /path/to/folder --cron "0 * * * *"
```
- **Tự phân biệt nội dung & Chuẩn hóa file:** OpenFang OCR PDF, đọc EXIF ảnh, và gán NER để tự di chuyển/rename folder (ví dụ: `MRI_spec.pdf` -> tự nhảy vào `tech/mri/modelX.pdf` qua setting `classify: {tech: sub/tech}`).
- **Tìm kiếm Semantic Đa Tiêu Chí:** Truy vấn ngôn ngữ tự nhiên sử dụng sức mạnh Vector + LLM (ví dụ: tìm file so sánh các máy giá siêu âm).
```bash
openfang search "so sánh máy siêu âm giá rẻ độ phân giải cao"
```
Kết quả được preview, rank relevance, có hỗ trợ gen thành table markdown hoặc xuất file CSV nhanh.

## 4. Workflows & Lịch báo tự động (Cron job)
Đặt lịch nhắc nhở rảnh tay:
```bash
openfang workflow create --cron "0 9 * * *" --channel telegram --prompt "Nhắc việc hàng ngày: [task]"
```
Tương tự, có thể định tuyến lịch nhắc, hay tạo luồng auto build `Knowledge Graph` hỗ trợ chatbot y tế (`MedicalDocBot`). Tùy chỉnh LLM routing bằng cách chỉnh cấu hình trong `config.toml`.
