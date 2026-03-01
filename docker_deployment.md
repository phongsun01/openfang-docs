# 🐳 **HƯỚNG DẪN TRIỂN KHAI OPENFANG QUA DOCKER**

Triển khai OpenFang bằng Docker giúp cô lập môi trường, dễ dàng quản lý dữ liệu và cấu hình nhất quán trên nhiều máy chủ khác nhau.

---

### **📌 1. CHUẨN BỊ**

Yêu cầu hệ thống phải có:
- **Docker** (phiên bản 20.10 trở lên)
- **Docker Compose** (V2)

---

### **📌 2. CẤU TRÚC THƯ MỤC KHUYẾN NGHỊ**

Sếp nên tạo một thư mục riêng để quản lý OpenFang:

```bash
mkdir openfang-docker && cd openfang-docker
mkdir data
touch .env
```

---

### **📌 3. FILE CẤU HÌNH `docker-compose.yml`**

Tạo file `docker-compose.yml` với nội dung sau:

```yaml
version: "3.8"

services:
  openfang:
    build: 
      context: https://github.com/RightNow-AI/openfang.git#main
    container_name: openfang-os
    ports:
      - "4200:4200"
    volumes:
      - ./data:/data
    environment:
      - OPENFANG_HOME=/data
      # API Keys
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - DASHSCOPE_API_KEY=${DASHSCOPE_API_KEY}
      - GROQ_API_KEY=${GROQ_API_KEY}
      - GEMINI_API_KEY=${GEMINI_API_KEY}
      # Telegram Bot
      - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
    restart: unless-stopped
```

---

### **📌 4. QUẢN LÝ BIẾN MÔI TRƯỜNG (`.env`)**

Sửa file `.env` để chứa các API key của sếp:

```ini
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
DASHSCOPE_API_KEY=sk-sp-...
GROQ_API_KEY=gsk_...
GEMINI_API_KEY=...
TELEGRAM_BOT_TOKEN=...
```

---

### **📌 5. KHỞI CHẠY HỆ THỐNG**

```bash
# Build và chạy container ở chế độ background
docker compose up -d --build

# Kiểm tra trạng thái
docker compose ps

# Xem logs thời gian thực
docker compose logs -f
```

Hệ thống sẽ khả dụng tại: **`http://localhost:4200`**

---

### **📌 6. LƯU Ý VỀ DỮ LIỆU VÀ CẤU HÌNH**

- **Persistence**: Toàn bộ cấu hình (`config.toml`), danh sách agents, và bộ nhớ (memory) sẽ được lưu tại thư mục `./data` trên máy chủ của sếp.
- **Cấu hình model**: Sếp có thể sửa file `./data/config.toml` trực tiếp. Sau khi sửa, hãy restart container:
  ```bash
  docker compose restart openfang
```

---

### **📌 7. NÂNG CẤP PHIÊN BẢN**

Khi có bản cập nhật mới trên GitHub, sếp chỉ cần chạy:

```bash
docker compose pull # Nếu dùng image từ GHCR
# Hoặc nếu build từ source:
docker compose up -d --build
```

---

### **📌 8. TRƯỜNG HỢP DÙNG CHO ALIBABA CODING PLAN**

Để dùng gói Coding Plan trong Docker, sếp hãy đảm bảo đã set `DASHSCOPE_API_KEY` trong `.env` và cập nhật file `config.toml` trong thư mục `data` tương tự như phiên bản macOS.

### **📌 9. ĐỒNG BỘ GIỮA CÁC MÁY (MAC <-> WIN)**

Vì sếp đang để thư mục project trong **Box-Box**, việc chuyển sang máy Win cực kỳ đơn giản:

1.  **Tự động đồng bộ**: Toàn bộ source code (đã có sẵn 9router và nút Edit em vừa sửa) sẽ tự chạy sang máy Win qua Box.
2.  **Chạy trên Win**: Sếp không cần cài Rust hay build tay. Chỉ cần cài **Docker Desktop** trên Windows.
3.  **Một lệnh duy nhất**: Mở Terminal tại thư mục `repo` trên Windows và gõ:
    ```bash
    docker compose up -d --build
    ```
    Docker sẽ tự dựng lại bộ máy OpenFang chuẩn chỉnh ngay trên máy văn phòng cho sếp!

---

> [!TIP]
> Do mình dùng volume `./data:/data`, toàn bộ danh sách Agent và cấu hình cũng sẽ được Box đồng bộ. Sếp tạo Agent ở nhà, lên cơ quan thấy luôn!
