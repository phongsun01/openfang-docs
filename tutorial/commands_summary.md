# 📚 **TỔNG HỢP CLI COMMANDS OPENFANG (v0.2.4+)**

---

## **🎯 MỤC LỤC**

1. [Lệnh Daemon (Khởi động & Quản lý)](#1-daemon-commands)
2. [Lệnh Hand/Agent (Quản lý Agents)](#2-hand-commands)
3. [Lệnh Chat & Message](#3-chat-commands)
4. [Lệnh Config & Setup](#4-config-commands)
5. [Lệnh Migration](#5-migration-commands)
6. [Lệnh Logs & Debug](#6-logs-commands)
7. [Lệnh Metrics & Stats](#7-metrics-commands)
8. [Lệnh Workflow](#8-workflow-commands)
9. [Lệnh MCP & Extensions](#9-mcp-commands)
10. [Lệnh Utility](#10-utility-commands)

---

## **1. DAEMON COMMANDS** 👻

Quản lý daemon OpenFang (tiến trình chạy nền).

### **`openfang start`**
Khởi động daemon OpenFang.

```bash
# Start daemon cơ bản
openfang start

# Start với verbose mode (xem chi tiết logs)
openfang start --verbose

# Start trên port cụ thể
openfang start --port 8080

# Start với IP binding cụ thể (cho Docker)
openfang start --host 0.0.0.0

# Start background (detached)
openfang start --daemon
```

**Output mẫu:**
```
✓ OpenFang daemon started
  PID: 12345
  Port: 4200
  Dashboard: http://localhost:4200
  API: http://localhost:4200/api
  Logs: ~/.openfang/logs/openfang.log
```

---

### **`openfang stop`**
Dừng daemon đang chạy.

```bash
# Stop gracefully
openfang stop

# Force stop (kill ngay lập tức)
openfang stop --force
```

**Output mẫu:**
```
✓ Daemon stopped (PID: 12345)
  Sessions archived: 3
  Pending approvals: 0
```

---

### **`openfang restart`**
Restart daemon.

```bash
# Restart cơ bản
openfang restart

# Restart với config reload
openfang restart --reload-config
```

---

### **`openfang status`**
Kiểm tra trạng thái daemon.

```bash
# Xem status cơ bản
openfang status

# Xem chi tiết đầy đủ
openfang status --verbose

# Output dạng JSON (cho scripting)
openfang status --json
```

**Output mẫu:**
```
┌────────────────────────────────────────┐
│ OpenFang Daemon Status                 │
├────────────────────────────────────────┤
│ Status:        Running                 │
│ PID:           12345                   │
│ Uptime:        3h 24m 17s              │
│ Port:          4200                    │
│ Version:       0.2.4                   │
│ Active Hands:  3                       │
│ Sessions:      7                       │
│ Memory Usage:  42 MB                   │
└────────────────────────────────────────┘
```

---

### **`openfang logs`**
Xem logs của daemon.

```bash
# Xem 100 dòng logs gần nhất
openfang logs --tail 100

# Theo dõi logs real-time (như tail -f)
openfang logs --follow

# Filter theo log level
openfang logs --level error
openfang logs --level warn
openfang logs --level info
openfang logs --level debug

# Xem logs từ thời điểm cụ thể
openfang logs --since "1h"
openfang logs --since "30m"
openfang logs --since "2024-03-01T10:00:00"

# Export logs ra file
openfang logs --tail 1000 --output ~/openfang-logs.txt
```

---

## **2. HAND COMMANDS** 🤖

Quản lý Hands (Agents) — nhóm lệnh quan trọng nhất.

### **`openfang hand list`**
Liệt kê tất cả hands.

```bash
# List cơ bản
openfang hand list

# List với chi tiết đầy đủ
openfang hand list --verbose

# Output JSON
openfang hand list --json

# List chỉ hands đang active
openfang hand list --status active

# List chỉ hands đang paused
openfang hand list --status paused
```

**Output mẫu:**
```
┌─────────────┬────────────┬───────────────────┬──────────────┐
│ Name        │ Status     │ Model             │ Last Active  │
├─────────────┼────────────┼───────────────────┼──────────────┤
│ assistant   │ active     │ gpt-4-turbo       │ 2 min ago    │
│ coder       │ active     │ claude-3-sonnet   │ 5 min ago    │
│ researcher  │ paused     │ gemini-pro        │ 1 hour ago   │
│ lead        │ active     │ gpt-4-turbo       │ 10 min ago   │
└─────────────┴────────────┴───────────────────┴──────────────┘
```

---

### **`openfang hand activate <name>`**
Kích hoạt một hand.

```bash
# Activate hand cơ bản
openfang hand activate researcher

# Activate với model cụ thể
openfang hand activate coder --model claude-3-opus

# Activate với provider cụ thể
openfang hand activate assistant --provider openai

# Activate và set schedule (cho hands tự động)
openfang hand activate lead --schedule "0 6 * * *"
```

**Output mẫu:**
```
✓ Hand 'researcher' activated
  Model: gemini-pro
  Provider: Google
  Session ID: sess_abc123
  Status: active
```

---

### **`openfang hand pause <name>`**
Tạm dừng một hand.

```bash
# Pause cơ bản
openfang hand pause researcher

# Pause với lý do
openfang hand pause coder --reason "Debugging session"

# Pause và lưu state
openfang hand pause assistant --save-state
```

---

### **`openfang hand status <name>`**
Xem trạng thái chi tiết của hand.

```bash
# Status cơ bản
openfang hand status assistant

# Status với metrics
openfang hand status coder --metrics

# Status với history
openfang hand status researcher --history

# Output JSON
openfang hand status assistant --json
```

**Output mẫu:**
```
┌─────────────────────────────────────────┐
│ Hand: assistant                         │
├─────────────────────────────────────────┤
│ Status:       active                    │
│ Model:        gpt-4-turbo               │
│ Provider:     OpenAI                    │
│ Session ID:   sess_abc123               │
│ Messages:     47                        │
│ Tokens Used:  125,430                   │
│ Cost:         $0.42                     │
│ Last Active:  2 minutes ago             │
│ Uptime:       3h 24m                    │
│ Tools Used:   file_read (23x),          │
│               web_fetch (12x)           │
└─────────────────────────────────────────┘
```

---

### **`openfang hand logs <name>`**
Xem logs của hand cụ thể.

```bash
# Xem 100 dòng logs gần nhất
openfang hand logs assistant --tail 100

# Theo dõi real-time
openfang hand logs coder --follow

# Filter theo level
openfang hand logs researcher --level error

# Xem logs từ thời điểm cụ thể
openfang hand logs lead --since "2h"

# Export logs
openfang hand logs assistant --output ~/hand-logs.txt
```

---

### **`openfang hand create <name>`**
Tạo hand mới.

```bash
# Tạo hand cơ bản
openfang hand create data-analyst

# Tạo với model và provider
openfang hand create ml-engineer \
  --model claude-3-sonnet \
  --provider anthropic

# Tạo với skills cụ thể
openfang hand create security-auditor \
  --skills security-checklist,code-reviewer \
  --config ~/.openfang/hands/security-config.toml

# Tạo từ template
openfang hand create my-agent --template assistant
```

---

### **`openfang hand delete <name>`**
Xóa hand.

```bash
# Xóa cơ bản (có xác nhận)
openfang hand delete old-hand

# Xóa không cần xác nhận
openfang hand delete old-hand --force

# Xóa và archive session trước
openfang hand delete old-hand --archive
```

---

### **`openfang hand config <name>`**
Xem/chỉnh config của hand.

```bash
# Xem config
openfang hand config assistant

# Edit config trong editor
openfang hand config coder --edit

# Get một key cụ thể
openfang hand config assistant --get model

# Set một key
openfang hand config assistant --set model=gpt-4-turbo

# Reset về default
openfang hand config assistant --reset
```

---

### **`openfang hand restart <name>`**
Restart một hand.

```bash
# Restart cơ bản
openfang hand restart assistant

# Restart với new session
openfang hand restart coder --new-session

# Restart và preserve history
openfang hand restart researcher --preserve-history
```

---

### **`openfang hand metrics <name>`**
Xem metrics chi tiết.

```bash
# Metrics cơ bản
openfang hand metrics assistant

# Metrics với period cụ thể
openfang hand metrics coder --period 7d
openfang hand metrics researcher --period 24h

# Output JSON
openfang hand metrics assistant --json

# Output CSV (cho Excel)
openfang hand metrics lead --format csv --output metrics.csv
```

**Output mẫu:**
```
┌──────────────────────────────────────────┐
│ Metrics: assistant (Last 7 days)         │
├──────────────────────────────────────────┤
│ Total Messages:        1,247             │
│ Total Tokens:          2,456,789         │
│ Total Cost:            $8.42             │
│ Avg Response Time:     1.2s              │
│ Tool Executions:       3,421             │
│ Success Rate:          98.7%             │
│ Most Used Tool:        file_read (847x)  │
│ Most Used Model:       gpt-4-turbo       │
└──────────────────────────────────────────┘
```

---

### **`openfang hand spawn <name>`**
Spawn một agent từ template có sẵn.

```bash
# Spawn coder agent
openfang hand spawn coder

# Spawn với name custom
openfang hand spawn my-coder --name project-coder

# Spawn với model custom
openfang hand spawn researcher --model gemini-ultra
```

---

## **3. CHAT COMMANDS** 💬

Gửi message và chat với agents.

### **`openfang chat <hand> "<message>"`**
Gửi message đến hand.

```bash
# Chat cơ bản
openfang chat assistant "Hello, how are you?"

# Chat với tiếng Việt
openfang chat assistant "Xin chào, hãy giúp tôi tạo một file Python"

# Chat với hand coder
openfang chat coder "Viết hàm tính giai thừa trong Python"

# Chat với researcher
openfang chat researcher "Tìm hiểu về xu hướng AI agents 2026"

# Chat với output file
openfang chat assistant "Tóm tắt file này" --input ~/document.pdf
```

**Output mẫu:**
```
assistant [2024-03-01 17:40:23]:
Xin chào! Tôi có thể giúp gì cho bạn hôm nay?

Tokens: 45 input, 23 output | Cost: $0.0012 | Time: 1.2s
```

---

### **`openfang chat --interactive`**
Vào chế độ chat tương tác (REPL).

```bash
# Vào interactive mode với assistant
openfang chat --interactive

# Vào interactive mode với hand cụ thể
openfang chat coder --interactive

# Interactive với model override
openfang chat --interactive --model gpt-4-turbo
```

**Trong interactive mode:**
```
You: Viết hàm quicksort trong Python
assistant: Được rồi, đây là implementation...

You: Giải thích cách hoạt động
assistant: Thuật toán này hoạt động theo nguyên tắc...

You: /exit  # Thoát
```

**Commands trong interactive mode:**
- `/exit` hoặc `/quit` — Thoát
- `/clear` — Xóa lịch sử chat
- `/model <name>` — Đổi model
- `/save <file>` — Lưu conversation ra file
- `/help` — Xem help

---

### **`openfang message <hand> "<message>"`**
Gửi message (alias của chat).

```bash
openfang message assistant "Hello"
```

---

## **4. CONFIG COMMANDS** ⚙️

Quản lý cấu hình.
### **`openfang init`**
Khởi tạo OpenFang lần đầu.

```bash
# Init cơ bản (interactive)
openfang init

# Init với provider cụ thể
openfang init --provider openai

# Init không interactive (cho scripting)
openfang init --non-interactive --api-key sk-xxx

# Init với config template
openfang init --template production
```

---

### **`openfang config`**
Xem/chỉnh config tổng.

```bash
# Xem config hiện tại
openfang config

# Edit config trong editor
openfang config --edit

# Get một key
openfang config --get providers.openai.api_key

# Set một key
openfang config --set providers.openai.api_key=sk-xxx

# Validate config
openfang config --validate

# Reset config về default
openfang config --reset
```

---

### **`openfang env`**
Quản lý biến môi trường.

```bash
# Xem tất cả env vars
openfang env list

# Get một var
openfang env get OPENAI_API_KEY

# Set một var
openfang env set OPENAI_API_KEY=sk-xxx

# Delete một var
openfang env delete OLD_API_KEY

# Export env vars ra file
openfang env export > .env
```

---

## **5. MIGRATION COMMANDS** 🔄

Migrate từ các framework khác.

### **`openfang migrate`**
Migrate từ platform khác.

```bash
# Migrate từ OpenClaw
openfang migrate --from openclaw

# Migrate từ path cụ thể
openfang migrate --from openclaw --path ~/.openclaw

# Migrate từ LangChain
openfang migrate --from langchain --path ~/langchain-project

# Dry run (xem trước không áp dụng)
openfang migrate --from openclaw --dry-run

# Migrate với backup
openfang migrate --from openclaw --backup
```

**Output mẫu:**
```
✓ Migration from OpenClaw completed
  Agents imported: 5
  Sessions migrated: 12
  Skills imported: 8
  Config converted: ✓
  Backup created: ~/.openfang/backup-20240301
```

---

## **6. LOGS COMMANDS** 📋

Xem và quản lý logs.

### **`openfang logs`**
Xem logs daemon (đã đề cập ở phần 1).

---

### **`openfang logs export`**
Export logs.

```bash
# Export toàn bộ logs
openfang logs export --output ~/openfang-logs.tar.gz

# Export logs của hand cụ thể
openfang logs export --hand assistant --output ~/assistant-logs.txt

# Export với filter thời gian
openfang logs export --since "24h" --output ~/logs-24h.txt

# Export dạng JSON
openfang logs export --format json --output ~/logs.json
```

---

### **`openfang logs analyze`**
Phân tích logs.

```bash
# Phân tích cơ bản
openfang logs analyze

# Phân tích với report chi tiết
openfang logs analyze --report

# Tìm errors
openfang logs analyze --find-errors

# Tìm warnings
openfang logs analyze --find-warnings
```

---

## **7. METRICS COMMANDS** 📊

Xem metrics và thống kê.

### **`openfang metrics`**
Xem metrics tổng của hệ thống.

```bash
# Metrics cơ bản
openfang metrics

# Metrics với period
openfang metrics --period 7d

# Metrics dạng JSON
openfang metrics --json

# Metrics dạng CSV
openfang metrics --format csv --output metrics.csv
```

**Output mẫu:**
```
┌──────────────────────────────────────────┐
│ OpenFang System Metrics (Last 7 days)    │
├──────────────────────────────────────────┤
│ Total Hands:           5                 │
│ Total Messages:        3,421             │
│ Total Tokens:          8,234,567         │
│ Total Cost:            $24.56            │
│ Avg Response Time:     1.4s              │
│ Tool Executions:       12,345            │
│ Success Rate:          98.9%             │
│ Uptime:                99.7%             │
└──────────────────────────────────────────┘
```

---

### **`openfang metrics cost`**
Xem chi tiết chi phí.

```bash
# Cost tổng
openfang metrics cost

# Cost theo hand
openfang metrics cost --by-hand

# Cost theo model
openfang metrics cost --by-model
# Cost theo ngày
openfang metrics cost --by-day --period 30d
```

---

### **`openfang metrics tokens`**
Xem chi tiết token usage.

```bash
# Tokens tổng
openfang metrics tokens

# Tokens theo hand
openfang metrics tokens --by-hand

# Tokens theo model
openfang metrics tokens --by-model
```

---

## **8. WORKFLOW COMMANDS** ⚡

Quản lý workflows (multi-agent pipelines).

### **`openfang workflow list`**
Liệt kê workflows.

```bash
# List workflows
openfang workflow list

# List với chi tiết
openfang workflow list --verbose
```

---

### **`openfang workflow run <name>`**
Chạy workflow.

```bash
# Run workflow
openfang workflow run lead-generation

# Run với input
openfang workflow run data-pipeline --input ~/data.csv

# Run dry-run
openfang workflow run complex-workflow --dry-run
```

---

### **`openfang workflow status <name>`**
Xem trạng thái workflow.

```bash
# Status workflow
openfang workflow status lead-generation

# Status với history
openfang workflow status data-pipeline --history
```

---

## **9. MCP COMMANDS** 🔌

Model Context Protocol & Extensions.

### **`openfang mcp list`**
Liệt kê MCP servers.

```bash
# List MCP servers
openfang mcp list

# List với status
openfang mcp list --status
```

---

### **`openfang mcp add <name>`**
Thêm MCP server.

```bash
# Thêm MCP server
openfang mcp add filesystem --config ~/.mcp/filesystem.json

# Thêm từ template
openfang mcp add postgres --template postgresql
```

---

### **`openfang mcp remove <name>`**
Xóa MCP server.

```bash
openfang mcp remove filesystem
```

---

### **`openfang extension list`**
Liệt kê extensions.

```bash
openfang extension list
```

---

### **`openfang extension install <name>`**
Cài extension.

```bash
openfang extension install github-integration
```

---

## **10. UTILITY COMMANDS** 🛠️

Các lệnh tiện ích khác.

### **`openfang --version`**
Xem version.

```bash
openfang --version
# Output: openfang 0.2.4
```

---

### **`openfang --help`**
Xem help tổng.

```bash
openfang --help
openfang hand --help
openfang chat --help
```

---

### **`openfang doctor`**
Chẩn đoán hệ thống.

```bash
# Chẩn đoán cơ bản
openfang doctor

# Chẩn đoán chi tiết
openfang doctor --verbose

# Chẩn đoán và fix tự động
openfang doctor --fix
```

**Output mẫu:**
```
┌──────────────────────────────────────────┐
│ OpenFang Health Check                    │
├──────────────────────────────────────────┤
│ Daemon:          ✓ Running               │
│ Config:          ✓ Valid                 │
│ API Keys:        ✓ 3 configured          │
│ Disk Space:      ✓ 45 GB available       │
│ Memory:          ✓ 42 MB used            │
│ Hands:           ✓ 5 active              │
│ Database:        ✓ Connected             │
│ Network:         ✓ Online                │
└──────────────────────────────────────────┘
```

---

### **`openfang update`**
Kiểm tra và cập nhật.

```bash
# Kiểm tra update
openfang update --check

# Update tự động
openfang update

# Update với backup
openfang update --backup
```

---

### **`openfang backup`**
Sao lưu dữ liệu.

```bash
# Backup cơ bản
openfang backup

# Backup với path cụ thể
openfang backup --output ~/backups/openfang-backup.tar.gz

# Backup chỉ config
openfang backup --config-only

# Backup chỉ memory
openfang backup --memory-only
```

---

### **`openfang restore`**
Phục hồi từ backup.

```bash
# Restore từ backup
openfang restore ~/backups/openfang-backup.tar.gz

# Restore với dry-run
openfang restore ~/backups/openfang-backup.tar.gz --dry-run
```

---

### **`openfang clean`**
Dọn dẹp dữ liệu.

```bash
# Dọn logs cũ
openfang clean --logs --older-than 30d

# Dọn sessions cũ
openfang clean --sessions --older-than 7d

# Dọn cache
openfang clean --cache

# Dọn tất cả (cẩn thận!)
openfang clean --all --force
```

---

## **📋 TÓM TẮT CÁC LỆNH THÔNG DỤNG NHẤT**

| Mục đích | Lệnh |
|----------|------|
| **Khởi động** | `openfang start` |
| **Dừng** | `openfang stop` |
| **Kiểm tra trạng thái** | `openfang status` |
| **Xem logs** | `openfang logs --tail 100` |
| **List hands** | `openfang hand list` |
| **Activate hand** | `openfang hand activate <name>` |
| **Chat với agent** | `openfang chat assistant "Hello"` |
| **Xem metrics** | `openfang metrics` |
| **Chẩn đoán** | `openfang doctor` |
| **Backup** | `openfang backup` |

---

## **💡 VÍ DỤ WORKFLOW THỰC TẾ**

```bash
# 1. Khởi động và kiểm tra
openfang start
openfang status

# 2. Kích hoạt các hands cần thiết
openfang hand activate assistant
openfang hand activate coder
openfang hand activate researcher

# 3. Chat với assistant
openfang chat assistant "Giúp tôi lên kế hoạch cho dự án mới"

# 4. Nhờ coder viết code
openfang chat coder "Viết API endpoint RESTful cho user management"

# 5. Nhờ researcher tìm thông tin
openfang chat researcher "Tìm xu hướng AI development 2026"

# 6. Xem metrics sau khi làm việc
openfang metrics --period 24h

# 7. Xem logs nếu có vấn đề
openfang logs --level error --tail 50

# 8. Backup trước khi dừng
openfang backup
openfang stop
```
