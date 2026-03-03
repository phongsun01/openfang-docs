# 📋 **WORKFLOW MẪU CHO MUASAMCONG.MPI.GOV.VN**

Dưới đây là các ví dụ workflow mẫu áp dụng cụ thể cho **muasamcong.mpi.gov.vn** (Hệ thống Mạng đấu thầu quốc gia Việt Nam):

---

### **WORKFLOW 1: GIÁM SÁT GÓI THẦU MỚI THEO TỪ KHÓA** 🎯

**Mục đích:** Tự động phát hiện gói thầu mới phù hợp với lĩnh vực kinh doanh của công ty.

```toml
# HAND.toml - ThauThauMonitor
[hand]
name = "thau-thau-monitor"
version = "1.0.0"
description = "Giám sát gói thầu mới từ muasamcong.mpi.gov.vn"

[schedule]
cron = "0 */2 * * *"  # Chạy mỗi 2 giờ
timezone = "Asia/Ho_Chi_Minh"

[tools]
required = ["web_fetch", "memory_store", "memory_recall", "agent_send"]

[settings]
keywords = ["phần mềm", "công nghệ thông tin", "hạ tầng mạng", "cloud"]
budget_min = 100000000  # 100 triệu VND
budget_max = 10000000000  # 10 tỷ VND
regions = ["Hà Nội", "TP.HCM", "Đà Nẵng"]
notification_channel = "telegram"

[metrics]
dashboard = ["packages_found", "qualified_packages", "alerts_sent"]
```

**System Prompt (tóm tắt):**
```
Bạn là ThauThauMonitor - Agent giám sát đấu thầu chuyên sâu.

NHIỆM VỤ:
1. Truy cập muasamcong.mpi.gov.vn, mục "Thông báo mời thầu"
2. Lọc gói thầu theo từ khóa đã cấu hình
3. Trích xuất: Mã gói thầu, Tên bên mời thầu, Giá gói thầu, Thời điểm đóng thầu
4. So sánh với memory (tránh trùng lặp)
5. Chấm điểm phù hợp 0-100 dựa trên: ngân sách, địa điểm, lĩnh vực
6. Gửi alert qua Telegram cho gói thầu >= 70 điểm
7. Lưu kết quả vào memory để lần sau không lặp

GUARDRAILS:
- Không tự động submit hồ sơ
- Chỉ thông báo, không ra quyết định
- Lưu trữ audit trail đầy đủ
```

**Output mẫu:**
```markdown
## 📢 Gói Thầu Mới Phát Hiện

| Mã | Tên gói thầu | Bên mời thầu | Giá (VND) | Đóng thầu | Score |
|----|--------------|--------------|-----------|-----------|-------|
| 2026001234 | Mua sắm hệ thống server | Bộ GTVT | 2.5 tỷ | 15/04/2026 | 85 |
| 2026001567 | Nâng cấp hạ tầng mạng | UBND TP.HCM | 800 triệu | 20/04/2026 | 72 |

✅ 2 gói thầu phù hợp gửi Telegram
💾 Đã lưu vào memory (key: thau_thau_history)
```

---

### **WORKFLOW 2: PHÂN TÍCH ĐỐI THỦ CẠNH TRANH** 🏆

**Mục đích:** Theo dõi các công ty thường xuyên trúng thầu trong lĩnh vực của bạn.

```toml
# HAND.toml - CompetitorAnalyzer
[hand]
name = "competitor-analyzer"
version = "1.0.0"
description = "Phân tích đối thủ cạnh tranh trên hệ thống đấu thầu"

[schedule]
cron = "0 8 * * 1"  # 8 AM thứ 2 hàng tuần
timezone = "Asia/Ho_Chi_Minh"

[tools]
required = ["web_fetch", "data_analyst", "memory_store", "file_write"]

[settings]
target_companies = ["Công ty A", "Công ty B", "Công ty C"]
sectors = ["CNTT", "Viễn thông", "Hạ tầng"]
analysis_depth = "12_months"
output_format = "markdown"

[metrics]
dashboard = ["competitors_tracked", "wins_analyzed", "reports_generated"]
```

**System Prompt (tóm tắt):**
```
Bạn là CompetitorAnalyzer - Agent phân tích cạnh tranh đấu thầu.

NHIỆM VỤ:
1. Truy cập muasamcong.mpi.gov.vn, mục "Kết quả lựa chọn nhà thầu"
2. Tìm kiếm theo tên công ty mục tiêu (12 tháng gần nhất)
3. Trích xuất: Số gói trúng, Tổng giá trị, Tỷ lệ thành công, Bên mời thầu chính
4. Phân tích xu hướng: Tháng nào mạnh? Lĩnh vực nào tập trung?
5. So sánh với dữ liệu lịch sử trong memory
6. Xuất báo cáo Markdown với biểu đồ (dùng data_analyst)
7. Lưu vào /reports/competitor_analysis_YYYY-MM.md

OUTPUT STRUCTURE:
- Tổng quan từng đối thủ
- Biểu đồ xu hướng 12 tháng
- Top 5 bên mời thầu hay làm việc với đối thủ
- Dự báo xu hướng quý tới
```

**Output mẫu:**
```markdown
# 📊 Báo Cáo Phân Tích Đối Thủ - Tuần 12/2026

> Thư ký Fang:
## Công ty XYZ Technology

| Metric | Giá trị | Thay đổi vs tháng trước |
|--------|---------|------------------------|
| Gói trúng | 14 | +3 |
| Tổng giá trị | 45.2 tỷ | +12% |
| Tỷ lệ thành công | 68% | +5% |

### Top Lĩnh Vực
1. Phần mềm quản lý (6 gói)
2. Hạ tầng mạng (4 gói)
3. Bảo mật (3 gói)

### Top Bên Mời Thầu
1. Bộ Tài Chính (3 gói)
2. UBND Hà Nội (2 gói)
3. Ngân hàng Vietcombank (2 gói)

📈 **Xu hướng:** Tăng mạnh vào lĩnh vực bảo mật từ Q1/2026
```

---

### **WORKFLOW 3: CẢNH BÁO SỚP ĐẾN HẠN NỘP HỒ SƠ** ⏰

**Mục đích:** Nhắc nhở trước khi đóng thầu các gói đã quan tâm.

```toml
# HAND.toml - DeadlineWatcher
[hand]
name = "deadline-watcher"
version = "1.0.0"
description = "Cảnh báo deadline nộp hồ sơ thầu"

[schedule]
cron = "0 9 * * *"  # 9 AM hàng ngày
timezone = "Asia/Ho_Chi_Minh"

[tools]
required = ["memory_recall", "web_fetch", "agent_send"]

[settings]
alert_schedule:
  - days_before: 7
    channel: "email"
  - days_before: 3
    channel: "telegram"
  - days_before: 1
    channel: "telegram+sms"
tracked_packages_key = "my_tracked_packages"

[metrics]
dashboard = ["packages_tracked", "alerts_sent", "deadlines_missed"]
```

**System Prompt (tóm tắt):**
```
Bạn là DeadlineWatcher - Agent cảnh báo deadline đấu thầu.

NHIỆM VỤ:
1. Lấy danh sách gói thầu đã lưu trong memory (key: my_tracked_packages)
2. Tính toán số ngày còn lại đến hạn nộp
3. Áp dụng alert_schedule để gửi thông báo đúng kênh
4. Cập nhật trạng thái: "Đã nộp" / "Bỏ qua" / "Quá hạn"
5. Gửi reminder chi tiết: Mã gói, Tên, Hạn nộp, Link hồ sơ

FORMAT ALERT:
🔴 1 ngày còn lại - [Mã gói] - Tên gói thầu
🟡 3 ngày còn lại - [Mã gói] - Tên gói thầu  
🟢 7 ngày còn lại - [Mã gói] - Tên gói thầu
```

---

### **WORKFLOW 4: TỔNG HỢP BÁO CÁO THÁNG** 📑

**Mục đích:** Tạo báo cáo tổng hợp hoạt động đấu thầu hàng tháng.

```toml
# HAND.toml - MonthlyReport
[hand]
name = "monthly-report"
version = "1.0.0"
description = "Báo cáo tổng hợp đấu thầu hàng tháng"

[schedule]
cron = "0 14 1 * *"  # 2 PM ngày 1 hàng tháng
timezone = "Asia/Ho_Chi_Minh"

[tools]
required = ["memory_recall", "data_analyst", "file_write", "agent_send"]

[settings]
report_sections:
  - new_packages_count
  - qualified_packages_count
  - submitted_packages_count
  - win_rate
  - competitor_summary
  - budget_analysis
output_path = "/reports/monthly_thau_thau_{YYYY-MM}.md"
recipients = ["email:ceo@company.com", "telegram:management_group"]

[metrics]
dashboard = ["reports_generated", "total_packages_analyzed"]
```

**Output mẫu:**
```markdown
# 📈 Báo Cáo Đấu Thầu Tháng 03/2026

## Tổng Quan
- Gói thầu mới phát hiện: 47
- Gói phù hợp (score >= 70): 18
- Đã nộp hồ sơ: 12
- Chờ kết quả: 8

## Tỷ Lệ Thành Công
| Tháng | Nộp | Trúng | Tỷ lệ |
|-------|-----|-------|-------|
| 01/2026 | 15 | 4 | 26.7% |
| 02/2026 | 10 | 3 | 30.0% |
| 03/2026 | 12 | 5 | 41.7% |

## Ngân Sách
- Tổng giá trị gói đã nộp: 85.5 tỷ
- Trung bình/gói: 7.1 tỷ
- Lớn nhất: 25 tỷ (Bộ Y Tế)
- Nhỏ nhất: 500 triệu (UBND Quận 1)

## Đối Thủ Nổi Bật
1. Công ty ABC - 8 gói trúng, 120 tỷ
2. Công ty XYZ - 6 gói trúng, 85 tỷ
3. Công ty 123 - 5 gói trúng, 60 tỷ

## Khuyến Nghị Tháng Tới
- Tăng focus vào lĩnh vực y tế (tỷ lệ trúng cao)
- Giảm submit gói dưới 1 tỷ (ROI thấp)
- Theo dõi sát 3 đối thủ top đầu
```

---

### **WORKFLOW 5: MULTI-AGENT PIPELINE - TỪ GIÁM SÁT ĐẾN DỰ BÁO** 🔄

**Mục đích:** Pipeline hoàn chỉnh từ thu thập → phân tích → dự báo → hành động.

```

> Thư ký Fang:
┌─────────────────────────────────────────────────────────────────┐
│                    PIPELINE: ThauThauFullAuto                   │
└─────────────────────────────────────────────────────────────────┘

Trigger: 6:00 AM hàng ngày

  ┌──────────────┐
  │   Collector  │  →  Giám sát muasamcong.mpi.gov.vn
  │    Hand      │  →  Phát hiện gói thầu mới
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │  Researcher  │  →  Tìm hiểu bên mời thầu (năng lực tài chính,
  │    Hand      │      lịch sử thanh toán, uy tín)
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │   Predictor  │  →  Dự đoán tỷ lệ trúng thầu dựa trên:
  │    Hand      │      - Giá chào trung bình ngành
  │              │      - Số đối thủ tham gia
  │              │      - Lịch sử quan hệ bên mời thầu
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │     Lead     │  →  Chấm điểm lead 0-100, xếp hạng ưu tiên
  │    Hand      │
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │    Browser   │  →  Tự động tải hồ sơ mời thầu (chờ phê duyệt)
  │    Hand      │  →  Điền form đăng ký (chờ phê duyệt)
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │   Telegram   │  →  Gửi báo cáo + danh sách chờ phê duyệt
  │   Channel    │
  └──────────────┘
```

```toml
# HAND.toml - ThauThauFullAuto
[hand]
name = "thau-thau-full-auto"
version = "2.0.0"
description = "Pipeline tự động hóa toàn bộ quy trình đấu thầu"

[schedule]
cron = "0 6 * * *"
timezone = "Asia/Ho_Chi_Minh"

[pipeline]
steps = ["collector", "researcher", "predictor", "lead", "browser", "notify"]
mode = "sequential"  # Chạy tuần tự, bước sau nhận output bước trước
timeout_per_step = 300  # 5 phút/bước
on_error = "continue"  # Lỗi bước nào thì log và qua bước tiếp

[approval_gates]
browser_download = "auto"  # Tự động tải hồ sơ
browser_submit = "manual"  # Chờ phê duyệt trước khi nộp
payment = "manual"  # Luôn chờ phê duyệt trước khi thanh toán

[tools]
required = ["web_fetch", "memory_store", "memory_recall", "agent_send", 
            "data_analyst", "file_write", "browser"]
```

---

## 🛠️ **HƯỚNG DẪN TRIỂN KHAI**

### **Bước 1: Tạo thư mục Hand**
```bash
mkdir -p ~/.openfang/hands/thau-thau-monitor
cd ~/.openfang/hands/thau-thau-monitor
```

### **Bước 2: Tạo file cấu hình**
```bash
# Tạo HAND.toml
nano HAND.toml  # Dán nội dung từ ví dụ trên

# Tạo system prompt
nano system_prompt.md

# Tạo SKILL.md (chuyên môn đấu thầu VN)
nano SKILL.md
```

### **Bước 3: Đăng ký Hand**
```bash
openfang hand register thau-thau-monitor
openfang hand activate thau-thau-monitor
```

### **Bước 4: Theo dõi**
```bash
# Xem trạng thái
openfang hand status thau-thau-monitor

# Xem logs
openfang hand logs thau-thau-monitor

# Tạm dừng
openfang hand pause thau-thau-monitor
```

---

## ⚠️ **LƯU Ý KHI LÀM VIỆC VỚI MUASAMCONG.MPI.GOV.VN**

1. **Rate Limiting:** Không fetch quá 1 request/3 giây để tránh bị chặn
2. **Authentication:** Một số mục cần đăng nhập → dùng Browser Hand với session persistence

> Thư ký Fang:
3. **Legal Compliance:** Chỉ thu thập thông tin công khai, không scrape dữ liệu cá nhân
4. **Data Freshness:** Dữ liệu có thể delay 1-2 ngày so với thực tế
5. **Backup Channel:** Luôn có kênh thông báo dự phòng (Telegram + Email)

---

## 🔍 **THEO DÕI ĐƠN VỊ CỤ THỂ TRÊN MUASAMCONG.MGI.GOV.VN**

> **Ngữ cảnh:** Theo dõi đơn vị được chỉ định đăng tải **kế hoạch lựa chọn nhà thầu** mới và **thông báo mời thầu** mới.

---

### **PHƯƠNG ÁN A: DÙNG COLLECTOR HAND (KHUYẾN NGHỊ)**

#### **1. Kích hoạt Collector Hand:**

```bash
openfang hand activate collector
openfang hand config collector --set target="muasamcong.mpi.gov.vn"
```

#### **2. Tạo file cấu hình custom:**

Tạo file `~/.openfang/hands/muasamcong-collector/HAND.toml`:

```toml
name = "muasamcong-monitor"
version = "1.0.0"
description = "Monitor kế hoạch lựa chọn nhà thầu và thông báo mời thầu"

[schedule]
enabled = true
cron = "0 */2 * * *"  # Chạy mỗi 2 giờ

[target]
base_url = "https://muasamcong.mpi.gov.vn"
unit_name = "TÊN ĐƠN VỊ CẦN THEO DÕI"  # Thay bằng tên thật
keywords = ["kế hoạch lựa chọn nhà thầu", "thông báo mời thầu"]

[filters]
unit_patterns = [
    "Bộ Giao thông Vận tải",
    "UBND Thành phố Hà Nội",
    # Thêm đơn vị cần monitor
]

[output]
format = "markdown"
save_to = "~/.openfang/data/muasamcong/"
alert_channels = ["telegram", "email"]

[alert]
enabled = true
on_new_item = true
on_change = true
```

#### **3. Tạo custom skill:**

```bash
mkdir -p ~/.openfang/skills/muasamcong-scraper
```

**`SKILL.toml`:**
```toml
name = "muasamcong-scraper"
version = "1.0.0"
category = "web-scraping"
description = "Scraper cho muasamcong.mpi.gov.vn"

[dependencies]
tools = ["web_fetch", "file_write", "memory_store"]

[config]
rate_limit = "1 request per 5 seconds"
retry_count = 3
timeout = 30
```

**`SKILL.md`:**
```markdown
# Muasamcong Scraper Skill

## Nhiệm vụ
- Fetch trang muasamcong.mpi.gov.vn
- Tìm kế hoạch lựa chọn nhà thầu mới
- Tìm thông báo mời thầu mới
- Lọc theo đơn vị chỉ định
- So sánh với dữ liệu cũ, chỉ alert cái MỚI

## Quy trình
1. Fetch trang chủ hoặc trang tìm kiếm
2. Parse HTML để extract danh sách thông báo
3. Lọc theo đơn vị và từ khóa
4. So sánh với memory (các thông báo đã biết)
5. Lưu thông báo mới vào memory
6. Gửi alert nếu có kết quả mới

## Lưu ý
- Website có thể chặn bot → dùng delay giữa các request
- Cần xử lý JavaScript → dùng browser tool nếu cần
- Tôn trọng robots.txt
```

---

### **PHƯƠNG ÁN B: DÙNG BROWSER HAND (NẾU WEB CẦN JS)**

```bash
openfang hand activate browser
openfang hand config browser --set target="muasamcong.mpi.gov.vn"
```

Browser Hand sẽ mở trang trong headless browser, chờ JS render, rồi extract nội dung.

---

### **PHƯƠNG ÁN C: WORKFLOW CUSTOM**

**`~/.openfang/workflows/muasamcong-monitor.toml`:**

```toml
name = "muasamcong-monitor"
description = "Monitor đấu thầu từ muasamcong.mpi.gov.vn"

[trigger]
type = "cron"
schedule = "0 */2 * * *"

[[steps]]
name = "fetch_page"
agent = "researcher"
prompt = """
Fetch trang https://muasamcong.mpi.gov.vn
Tìm: Kế hoạch lựa chọn nhà thầu, Thông báo mời thầu
Lọc theo đơn vị: {unit_name}
"""

[[steps]]
name = "parse_results"
agent = "assistant"
prompt = """
Parse kết quả từ bước trước, extract các trường:
- Số thông báo, Tên gói thầu, Đơn vị mời thầu, Ngày đăng, Link chi tiết
"""

[[steps]]
name = "compare_with_history"
agent = "assistant"
prompt = "So sánh với memory. Chỉ giữ thông báo CHƯA CÓ trong lịch sử."

[[steps]]
name = "save_and_alert"
agent = "assistant"
prompt = """
Lưu thông báo mới vào memory.
Gửi alert qua Telegram với: số lượng mới, tóm tắt, link chi tiết.
"""
```

---

### **📊 KẾT QUẢ MONG ĐỢI**

```
📢 ALERT: Đấu thầu mới từ muasamcong.mpi.gov.vn

Đơn vị: Bộ Giao thông Vận tải
Thời gian phát hiện: 2026-03-02 14:30

📋 Thông báo mới (3):

1. Gói thầu: Xây dựng cầu XYZ
   - Số TBMT: 2026001234 | Ngày: 2026-03-02 | Giá: 50 tỷ VND
   - 🔗 https://muasamcong.mpi.gov.vn/...

2. Kế hoạch LCNT: Dự án ABC
   - Số KHLCNT: 2026005678 | Ngày: 2026-03-01
   - 🔗 https://muasamcong.mpi.gov.vn/...
```

---

### **⚠️ Bảng xử lý sự cố**

| Vấn đề | Giải pháp |
|--------|-----------|
| Website chặn bot | Dùng Browser Hand (Playwright headless) |
| Cần JavaScript | Browser Hand với Playwright |
| Cần đăng nhập | Cấu hình session/cookies trong Browser Hand |
| CAPTCHA | Cần dịch vụ giải CAPTCHA bên thứ 3 |
| Rate limiting | Cấu hình `rate_limit` trong skill |

---

### **💡 Câu hỏi để setup chính xác**

Để cấu hình đúng cho sếp, em cần biết:

1. **Tên đơn vị cụ thể** muốn monitor? (VD: "Bộ GTVT", "UBND Hà Nội")
2. **Tần suất check** mong muốn? (30 phút / 1 giờ / 6 giờ / hàng ngày?)
3. **Kênh nhận alert** ưa thích? (Telegram / Email / Slack / SMS?)
4. **Cần lưu trữ lịch sử** không? (để tra cứu hoặc export Excel?)
