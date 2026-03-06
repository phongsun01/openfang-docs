# Hướng dẫn Kiểm soát và Tự phục hồi Bot (Watchdog)

Tài liệu này hướng dẫn cách thiết lập và vận hành hệ thống "Chó săn" (Watchdog) để đảm bảo OpenFang luôn trong trạng thái sẵn sàng, tự động xử lý khi Bot bị treo hoặc ngắt kết nối.

---

## 1. Tác dụng của Watchdog

Trong quá trình vận hành lâu dài trên MacOS hoặc máy chủ, OpenFang có thể gặp các tình trạng:
- **Treo tiến trình (Hang):** Bot vẫn chạy nhưng không phản hồi tin nhắn do lỗi mạng hoặc tràn bộ nhớ đệm.
- **Ngắt kết nối ngầm (Disconnect):** Kết nối Telegram/Zalo bị đứt nhưng daemon không tự khởi động lại.
- **Lỗi hệ thống:** Các xung đột tài nguyên khiến API nội bộ bị đóng.

**Watchdog giải quyết triệt để vấn đề này bằng cách:**
1. **Kiểm tra định kỳ (Hourly Check):** Cứ mỗi 1 giờ, một script nhỏ sẽ "gọi cửa" (ping) vào API sức khỏe của Bot.
2. **Phán đoán thông minh:** Nếu API trả về `ok`, hệ thống giữ nguyên. Nếu API không phản hồi sau 10 giây, Watchdog xác định Bot đã "ngất".
3. **Tự động hồi sinh:** Watchdog sẽ tự động `stop` cưỡng bức tiến trình cũ và thực hiện `start` để làm mới hoàn toàn session kết nối.
4. **Nhật ký minh bạch:** Ghi lại chính xác thời điểm Bot gặp sự cố và thời điểm hồi sinh thành công vào file log.

---

## 2. Quy trình tích hợp (Từng bước)

### Bước 1: Tạo Script Giám sát
Tạo file script tại đường dẫn `openfang-docs/scripts/openfang_watchdog.sh` với nội dung kiểm tra cổng API mặc định (4200).

```bash
#!/bin/bash
# Kiểm tra sức khỏe Bot qua API localhost:4200
HEALTH_URL="http://127.0.0.1:4200/api/health"
LOG_FILE="$HOME/.openfang/watchdog.log"

RESPONSE=$(curl -sf --max-time 10 "$HEALTH_URL" 2>/dev/null)

if echo "$RESPONSE" | grep -q '"status":"ok"'; then
    echo "[$(date)] OK - Bot hoạt động bình thường." >> "$LOG_FILE"
else
    echo "[$(date)] ⚠️ Bot treo. Đang restart..." >> "$LOG_FILE"
    openfang stop 2>/dev/null || true
    sleep 3
    openfang start &
    echo "[$(date)] ✅ Đã restart thành công." >> "$LOG_FILE"
fi
```

### Bước 2: Cấp quyền thực thi
Mở Terminal và chạy lệnh sau để hệ thống được phép chạy script này:
```bash
chmod +x "/Users/xitrum/Library/CloudStorage/Box-Box/Tai lieu - Phong/Study2/Antigravity/Openfang/openfang-docs/scripts/openfang_watchdog.sh"
```

### Bước 3: Lên lịch tự động (Crontab)
Để script chạy ngầm hàng giờ mà không cần bạn can thiệp thủ công:

1. Gõ lệnh: `crontab -e`
2. Thêm dòng sau vào cuối file (lưu ý dùng đường dẫn tuyệt đối):
```cron
0 * * * * /Users/xitrum/Library/CloudStorage/Box-Box/Tai\ lieu\ -\ Phong/Study2/Antigravity/Openfang/openfang-docs/scripts/openfang_watchdog.sh
```
*Giải thích: `0 * * * *` nghĩa là chạy vào phút thứ 0 của mỗi giờ chẵn.*

---

## 3. Cách kiểm tra trạng thái

Bạn có thể theo dõi "nhật ký chiến trường" của Chó săn bất cứ lúc nào bằng lệnh:
```bash
tail -f ~/.openfang/watchdog.log
```

Nếu thấy dòng `OK - Bot hoạt động bình thường`, bạn có thể hoàn toàn yên tâm là hệ thống đang cực kỳ ổn định.

---
*Tài liệu cập nhật lần cuối: 2026-03-07*
