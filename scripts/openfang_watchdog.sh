#!/bin/bash
# ============================================================
# OpenFang Watchdog - Tự động theo dõi và khởi động lại Bot
# Chạy mỗi 1 giờ qua crontab: 0 * * * * /path/to/openfang_watchdog.sh
# ============================================================

HEALTH_URL="http://127.0.0.1:4200/api/health"
LOG_FILE="$HOME/.openfang/watchdog.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Đảm bảo thư mục log tồn tại
mkdir -p "$HOME/.openfang"

# Kiểm tra sức khỏe API
RESPONSE=$(curl -sf --max-time 10 "$HEALTH_URL" 2>/dev/null)

if echo "$RESPONSE" | grep -q '"status":"ok"'; then
    # Bot đang chạy bình thường - không làm gì
    echo "[$TIMESTAMP] OK - Bot đang hoạt động bình thường." >> "$LOG_FILE"
else
    # Bot không phản hồi, tiến hành restart
    echo "[$TIMESTAMP] ⚠️  Bot treo hoặc ngừng hoạt động. Đang restart..." >> "$LOG_FILE"
    
    # Tắt daemon cũ (nếu còn)
    /Users/xitrum/.cargo/bin/openfang stop 2>/dev/null || true
    sleep 3
    
    # Khởi động lại daemon trong nền
    /Users/xitrum/.cargo/bin/openfang start &
    
    echo "[$TIMESTAMP] ✅ Đã restart OpenFang daemon thành công." >> "$LOG_FILE"
fi

# Giữ log không quá 500 dòng
tail -n 500 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
