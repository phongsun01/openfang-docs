# 🍎 **HƯỚNG DẪN UPGRADE OPENFANG TRÊN MACOS**

### **📌 BƯỚC 1: KIỂM TRA HỆ THỐNG**

```bash
# Kiểm tra architecture (Apple Silicon hay Intel)
uname -m

# Kết quả:
# - arm64 → Apple Silicon (M1/M2/M3)
# - x86_64 → Intel Mac
```

---

### **📌 BƯỚC 2: DỪNG DAEMON HIỆN TẠI**

```bash
# Dừng daemon đang chạy
openfang stop

# Kiểm tra trạng thái
openfang status
# Nên hiển thị: "Daemon is not running"
```

---

### **📌 BƯỚC 3: BACKUP CẤU HÌNH**

```bash
# Backup config hiện tại
cp ~/.openfang/config.toml ~/.openfang/config.toml.backup.$(date +%Y%m%d)

# Backup memory (nếu có dữ liệu quan trọng)
cp -r ~/.openfang/memory ~/.openfang/memory.backup.$(date +%Y%m%d)

# Xác nhận backup
ls -la ~/.openfang/*.backup.*
```

---

### **📌 BƯỚC 4: TẢI & CÀI ĐẶT BẢN MỚI NHẤT**

#### **Cách 1: Dùng install script (khuyến nghị)**

```bash
curl -fsSL https://openfang.sh/install | sh
```

Script sẽ tự động:
- ✅ Detect macOS architecture
- ✅ Tải binary phù hợp
- ✅ Giải nén vào `/usr/local/bin` hoặc `~/.local/bin`
- ✅ Cập nhật PATH nếu cần

---

#### **Cách 2: Tải thủ công từ GitHub**

**Cho Apple Silicon (M1/M2/M3):**
```bash
cd /tmp
curl -LO https://github.com/RightNow-AI/openfang/releases/download/v0.2.3/openfang-aarch64-apple-darwin.tar.gz
tar -xzf openfang-aarch64-apple-darwin.tar.gz
sudo mv openfang /usr/local/bin/
```

**Cho Intel Mac:**
```bash
cd /tmp
curl -LO https://github.com/RightNow-AI/openfang/releases/download/v0.2.3/openfang-x86_64-apple-darwin.tar.gz
tar -xzf openfang-x86_64-apple-darwin.tar.gz
sudo mv openfang /usr/local/bin/
```

---

### **📌 BƯỚC 5: XÁC MINH CÀI ĐẶT**

```bash
# Kiểm tra version
openfang --version
# ✅ Nên hiển thị: openfang 0.2.3

# Kiểm tra binary location
which openfang
# ✅ Nên hiển thị: /usr/local/bin/openfang

# Kiểm tra permissions
ls -la $(which openfang)
# ✅ Nên có: -rwxr-xr-x
```

---

### **📌 BƯỚC 6: KHỞI ĐỘNG LẠI DAEMON**

```bash
# Start daemon
openfang start

# Kiểm tra trạng thái
openfang status

# Xem logs (nếu có lỗi)
openfang logs
```

---

### **📌 BƯỚC 7: TRUY CẬP DASHBOARD**

```bash
# Mở dashboard trong browser
open http://localhost:4200
```

Kiểm tra:
- ✅ Dashboard load thành công
- ✅ Version hiển thị đúng (v0.2.3)
- ✅ Các Hands vẫn hoạt động
- ✅ Providers vẫn kết nối được

---

## 🔍 **XÁC MINH SAU UPGRADE**

```bash
# Test cron scheduler (đã fix trong v0.2.1)
openfang hand list

# Test một lệnh đơn giải
openfang chat assistant "Hello, test sau upgrade"

# Kiểm tra các hands đang active
openfang hand status
```

---

## ⚠️ **XỬ LÝ SỰ CỐ THƯỜNG GẶP**

### **Lỗi 1: `command not found: openfang`**
```bash
# Thêm vào PATH
export PATH="$HOME/.local/bin:$PATH"

# Hoặc symlink thủ công
sudo ln -s /tmp/openfang /usr/local/bin/openfang
```

### **Lỗi 2: `permission denied`**
```bash
sudo chmod +x /usr/local/bin/openfang
```

### **Lỗi 3: Daemon không start được**
```bash
# Xem chi tiết lỗi
openfang logs --tail 100

# Thử start với verbose mode
openfang start --verbose
```

### **Lỗi 4: Config không tương thích**
```bash
# Restore config backup
cp ~/.openfang/config.toml.backup.* ~/.openfang/config.toml

# Re-init với config mới
openfang init --migrate
```

---

## 📊 **TÓM TẮT QUÁ TRÌNH UPGRADE**

| Bước | Lệnh | Thời gian |
|------|------|-----------|
| 1. Dừng daemon | `openfang stop` | 5s |
| 2. Backup config | `cp ~/.openfang/config.toml ...` | 2s |
| 3. Tải bản mới | `curl -fsSL https://openfang.sh/install \| sh` | 30s |
| 4. Xác minh | `openfang --version` | 2s |
| 5. Start lại | `openfang start` | 10s |
| **Tổng** | | **~1 phút** |

---

## ✅ **CHECKLIST SAU UPGRADE**

- [ ] Version hiển thị đúng: **v0.2.3**
- [ ] Daemon start thành công

> Thư ký Fang:
- [ ] Dashboard truy cập được tại `http://localhost:4200`
- [ ] Các hands vẫn active
- [ ] Providers vẫn kết nối được
- [ ] Test gửi message thành công
- [ ] Cron scheduler chạy đúng lịch (không fire mỗi phút)
