# 📚 **PHẦN 1: CLI SUBCOMMANDS CHO HANDS (AGENTS)**

## **🔍 TỔNG QUAN**

Từ v0.2.4, OpenFang đã thêm bộ CLI subcommands chuyên biệt để quản lý Hands (Agents) mà không cần qua Dashboard.

---

## **📋 DANH SÁCH CÁC LỆNH**

### **1. `openfang hand list`**
```bash
# Liệt kê tất cả hands đang đăng ký
openfang hand list

# Output mẫu:
┌─────────────┬────────────┬──────────┬──────────────┐
│ Name        │ Status     │ Model    │ Last Active  │
├─────────────┼────────────┼──────────┼──────────────┤
│ assistant   │ active     │ gpt-4    │ 2 min ago    │
│ coder       │ paused     │ claude-3 │ 1 hour ago   │
│ researcher  │ active     │ gemini   │ 5 min ago    │
└─────────────┴────────────┴──────────┴──────────────┘
```

---

### **2. `openfang hand activate <name>`**
```bash
# Kích hoạt một hand đang paused
openfang hand activate coder

# Output:
✓ Hand 'coder' đã được kích hoạt
  Model: claude-3-sonnet
  Status: active
```

---

### **3. `openfang hand pause <name>`**
```bash
# Tạm dừng một hand đang active
openfang hand pause researcher

# Output:
✓ Hand 'researcher' đã được tạm dừng
  Reason: User requested
```

---

### **4. `openfang hand status <name>`**
```bash
# Xem chi tiết trạng thái của một hand
openfang hand status assistant

# Output mẫu:
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
└─────────────────────────────────────────┘
```

---

### **5. `openfang hand logs <name>`**
```bash
# Xem logs của một hand
openfang hand logs assistant --tail 50

# Options:
--tail <n>      # Số dòng logs gần nhất (default: 100)
--follow        # Theo dõi logs real-time (như tail -f)
--level <lvl>   # Filter theo log level (info, warn, error, debug)
--since <time>  # Logs từ thời điểm nào (e.g., "1h", "30m", "2024-01-01")

# Output mẫu:
[2024-03-01 17:40:23] INFO  Tool executed: file_read (workspace/AGENTS.md)
[2024-03-01 17:40:25] INFO  Tool executed: web_fetch (https://example.com)
[2024-03-01 17:40:28] DEBUG Token usage: 1,234 input, 567 output
[2024-03-01 17:40:30] INFO  Message sent to user (cost: $0.0023)
```

---

### **6. `openfang hand create <name>`**
```bash
# Tạo hand mới
openfang hand create data-analyst --model claude-3-sonnet --provider anthropic

# Options:
--model <name>      # Model mặc định
--provider <name>   # Provider mặc định
--skills <list>     # Skills gán cho hand (comma-separated)
--config <path>     # Path tới config file tùy chỉnh
```

---

### **7. `openfang hand delete <name>`**
```bash
# Xóa một hand
openfang hand delete old-hand --force

# ⚠️ Lưu ý: Xóa luôn sessions và memory của hand đó
```

---

### **8. `openfang hand config <name>`**
```bash
# Xem hoặc chỉnh config của hand
openfang hand config assistant

# Edit config:
openfang hand config assistant --edit

# Options:
--edit              # Mở editor để chỉnh config
--get <key>         # Lấy giá trị của một key cụ thể
--set <key>=<value> # Set giá trị cho một key
--reset             # Reset về default config
```

---

### **9. `openfang hand restart <name>`**
```bash
# Restart một hand (useful khi bị stuck)
openfang hand restart assistant

# Output:
✓ Hand 'assistant' đã được restart
  New session ID: sess_xyz789
  Previous session archived
```

---

### **10. `openfang hand metrics <name>`**
```bash
# Xem metrics chi tiết (tokens, cost, performance)
openfang hand metrics assistant --period 7d

# Options:
--period <time>     # Thời gian xem (1h, 24h, 7d, 30d)
--format <fmt>      # Output format (table, json, csv)

# Output mẫu:
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

## **🎯 VÍ DỤ WORKFLOW THỰC TẾ**

```bash
# 1. Kiểm tra tất cả hands
openfang hand list

# 2. Xem chi tiết hand bị vấn đề
openfang hand status coder

# 3. Xem logs để debug
openfang hand logs coder --tail 100 --level error

# 4. Restart nếu cần
openfang hand restart coder

# 5. Xem metrics sau restart
openfang hand metrics coder --period 24h

# 6. Tạm dừng hand không dùng đến
openfang hand pause old-researcher
```

---

# 📄 **PHẦN 2: GIẢI THÍCH CÁC FILE .MD CỦA HAND/AGENT**

Mỗi hand/agent trong OpenFang có một bộ file cấu hình dạng `.md` để định nghĩa identity, behavior, và capabilities. Đây là kiến trúc **"Agent-as-Code"**.

---

## **📂 CẤU TRÚC THƯ MỤC MỘT HAND**

```
~/.openfang/hands/<hand-name>/
├── AGENT.json          # Metadata JSON (ID, created_at, etc.)
├── AGENTS.md           # Behavioral guidelines (chi tiết)
├── SOUL.md             # Core identity & personality
├── IDENTITY.md         # Visual identity & persona config
├── MEMORY.md           # Long-term memory notes
├── USER.md             # User profile & preferences
├── TOOLS.md            # Tool access & environment notes
├── BOOTSTRAP.md        # Initialization instructions
└── skills/             # Folder chứa skills
    ├── aws.md
    ├── python-expert.md
    └── ...
```

---

## **📋 CHI TIẾT TỪNG FILE**

### **1. `SOUL.md` — CỐT LÕI NHÂN CÁCH**

**Mục đích:** Định nghĩa "linh hồn" của agent — tính cách cốt lõi, giá trị, và cách ứng xử cơ bản.

**Nội dung điển hình:**
```markdown
# Soul
You are assistant. General-purpose assistant agent. 
The default OpenFang agent for everyday tasks, questions, and conversations.

Be genuinely helpful. Have opinions. Be resourceful before asking.
Treat user data with respect — you are a guest in their life.
```

**Ảnh hưởng:**
- ✅ Quyết định tone giọng (warm, professional, casual, etc.)
- ✅ Quyết định mức độ chủ động (resourceful vs. ask-first)
- ✅ Quyết định cách xử lý tình huống mơ hồ

**Khi nào nên edit:**
- Muốn thay đổi tính cách agent (ví dụ: từ "warm" → "professional")
- Muốn agent có opinions rõ ràng hơn hoặc ít hơn
- Muốn thay đổi mức độ tự chủ của agent

---
### **2. `IDENTITY.md` — ĐỊNH DANH TRỰC QUAN**

**Mục đích:** Cấu hình metadata về visual identity và personality style.

**Nội dung điển hình:**
```yaml
---
name: assistant
archetype: assistant
vibe: helpful
emoji: 🤖
avatar_url: https://example.com/avatar.png
greeting_style: warm
color: "#3B82F6"
---
# Identity
<!-- Visual identity and personality at a glance. Edit these fields freely. -->
```

**Các trường quan trọng:**

| Field | Mô tả | Ví dụ |
|-------|-------|-------|
| `name` | Tên hiển thị | `assistant`, `coder`, `researcher` |
| `archetype` | Loại agent | `assistant`, `specialist`, `executor` |
| `vibe` | Cảm giác tổng thể | `helpful`, `professional`, `witty` |
| `emoji` | Emoji đại diện | `🤖`, `📊`, `✍️`, `🔧` |
| `avatar_url` | URL avatar | Link ảnh PNG/SVG |
| `greeting_style` | Phong cách chào | `warm`, `formal`, `casual` |
| `color` | Màu chủ đạo (hex) | `#3B82F6`, `#10B981` |

**Khi nào nên edit:**
- Muốn custom hóa giao diện agent trong Dashboard
- Muốn phân biệt visual giữa các hands
- Muốn tạo branding riêng cho agent

---

### **3. `AGENTS.md` — HƯỚNG DẪN HÀNH VI CHI TIẾT**

**Mục đích:** Tài liệu chi tiết về cách agent nên hành xử trong các tình huống cụ thể.

**Nội dung điển hình:**
```markdown
# Agent Behavioral Guidelines

## Core Principles
- Act first, narrate second. Use tools to accomplish tasks.
- Batch tool calls when possible.
- When task is ambiguous, ask ONE clarifying question.

## Tool Usage Protocols
- file_read BEFORE file_write — always understand what exists.
- web_search for current info, web_fetch for specific URLs.
- shell_exec: explain destructive commands before running.

## Response Style
- Lead with the answer or result, not process narration.
- Keep responses concise unless user asks for detail.
- Use formatting (headers, lists, code blocks) for readability.
```

**Ảnh hưởng:**
- ✅ Quyết định workflow thực thi task
- ✅ Quyết định cách dùng tools
- ✅ Quyết định format output

**Khi nào nên edit:**
- Muốn thay đổi quy trình làm việc của agent
- Muốn thêm/quy định cụ thể về tool usage
- Muốn chuẩn hóa response style

---

### **4. `MEMORY.md` — BỘ NHỚ DÀI HẠN**

**Mục đích:** Lưu trữ kiến thức và context mà agent học được qua các session.

**Nội dung điển hình:**
```markdown
# Long-Term Memory
<!-- Curated knowledge the agent preserves across sessions -->

## User Preferences
- Prefers concise answers
- Uses macOS (Apple Silicon)
- Works primarily in TypeScript/Node.js

## Project Context
- Project X: Using Next.js 14, deployed on Vercel
- Project Y: Python FastAPI backend, PostgreSQL

## Important Decisions
- 2024-02-15: Chose Tailwind over CSS Modules
- 2024-02-20: Decided to use Supabase for auth
```

**Ảnh hưởng:**
- ✅ Giúp agent nhớ context qua sessions
- ✅ Tránh phải hỏi lại thông tin đã biết
- ✅ Tạo continuity trong conversations

**Khi nào nên edit:**
- Muốn agent nhớ thông tin quan trọng về user
- Muốn lưu context dự án dài hạn
- Muốn ghi chú các decisions quan trọng

---

### **5. `USER.md` — HỒ SƠ NGƯỜI DÙNG**

**Mục đích:** Thông tin về user mà agent phục vụ.

**Nội dung điển hình:**
```markdown
# User
<!-- Updated by the agent as it learns about the user -->

- Name: Thẫ̃ ký Fang
- Timezone: Asia/Ho_Chi_Minh (UTC+7)
- Language: Vietnamese (primary), English
- Role: Software Engineer / Tech Lead
- Preferences:
  - Concise, direct communication
  - Code examples over explanations
  - Prefers CLI over GUI
  - Working hours: 9 AM - 6 PM ICT
```

**Khác biệt với MEMORY.md:**
- `USER.md` = Thông tin về **người dùng** (name, timezone, preferences)
- `MEMORY.md` = Kiến thức **tổng quát** agent học được (projects, decisions, facts)

**Khi nào nên edit:**
- Cập nhật thông tin cá nhân
- Thay đổi preferences làm việc
- Thêm context về role/công việc

---

### **6. `TOOLS.md` — CẤU HÌNH MÔI TRƯỜNG TOOLS**

**Mục đích:** Ghi chú về tools và environment mà agent có thể truy cập.

**Nội dung điển hình:**
```markdown
# Tools & Environment
<!-- Agent-specific environment notes (not synced) -->

## Available Tools
- file_read, file_write, file_list
- shell_exec (with approval)
- web_fetch, web_search
- memory_store, memory_recall
- agent_send, agent_list

## Environment Variables
- OPENFANG_HOME: ~/.openfang
- WORKSPACE: /Users/xitrum/.openfang/workspaces/assistant

## Restrictions
- shell_exec requires human approval
- Cannot access paths outside workspace without MCP
- web_fetch blocked for SSRF-sensitive IPs
```

**Khi nào nên edit:**
- Muốn document tools custom
- Muốn ghi chú restrictions đặc biệt
- Muốn thêm environment-specific notes

---

### **7. `BOOTSTRAP.md` — HƯỚNG DẪN KHỞI TẠO**

**Mục đích:** Instructions để setup/re-setup agent từ đầu.

**Nội dung điển hình:**
```markdown
# Bootstrap Guide

## Initial Setup
1. Copy this folder to ~/.openfang/hands/<name>
2. Edit IDENTITY.md với name và archetype phù hợp
3. Edit SOUL.md với personality mong muốn
4. Run: openfang hand activate <name>

## Dependencies
- Node.js 18+
- Python 3.10+ (cho data-analyst hand)
- AWS CLI configured (cho aws hand)

## First Run Checklist
- [ ] Verify API keys in config.toml
- [ ] Test basic tool execution
- [ ] Confirm memory persistence
```

**Khi nào nên edit:**
- Tạo hand mới từ template
- Document dependencies đặc biệt
- Hướng dẫn onboarding cho team members

---

### **8. `AGENT.json` — METADATA JSON**

**Mục đích:** Machine-readable metadata về agent.

**Nội dung điển hình:**
```json
{
  "id": "asst_65cee988",
  "name": "assistant",
  "archetype": "assistant",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-03-01T17:40:00Z",
  "model": "gpt-4-turbo",
  "provider": "openai",
  "skills": ["general", "writing", "research"],
  "status": "active",
  "workspace": "assistant-65cee988"
}
```

**Khi nào nên edit:**
- Thường không edit thủ công (auto-generated)
- Có thể edit để migrate agent sang workspace khác
- Có thể edit để thay đổi model/provider mặc định

---

## **📊 TÓM TẮT MỐI QUAN HỆ GIỮA CÁC FILE**

```
┌─────────────────────────────────────────────────────────────┐
│                      AGENT (HAND)                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  SOUL.md          → "Tôi là ai?" (core personality)         │
│  IDENTITY.md      → "Tôi trông thế nào?" (visual config)    │
│  AGENTS.md        → "Tôi hành xử ra sao?" (behavior rules)  │
│  USER.md          → "Tôi phục vụ ai?" (user profile)        │
│  MEMORY.md        → "Tôi nhớ gì?" (long-term knowledge)     │
│  TOOLS.md         → "Tôi có thể làm gì?" (capabilities)     │
│  BOOTSTRAP.md     → "Tôi được tạo ra sao?" (setup guide)    │
│  AGENT.json       → "Metadata của tôi?" (machine-readable)  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## **🎯 VÍ DỤ THỰC TẾ: TẠO HAND MỚI**

```bash
# 1. Tạo folder mới
mkdir -p ~/.openfang/hands/data-analyst

# 2. Copy template từ assistant
cp -r ~/.openfang/hands/assistant/* ~/.openfang/hands/data-analyst/

# 3. Edit các file chính
# IDENTITY.md → đổi name: data-analyst, emoji: 📊
# SOUL.md → đổi sang personality phân tích dữ liệu
# AGENTS.md → thêm guidelines về data analysis
# USER.md → giữ nguyên (cùng user)

# 4. Activate hand mới
openfang hand activate data-analyst

# 5. Verify
openfang hand status data-analyst
```

---

## **💡 MẸO SỬ DỤNG**

| Mục đích | File nên edit |
|----------|---------------|
| Đổi tính cách agent | `SOUL.md` |
| Đổi giao diện/dashboard | `IDENTITY.md` |
| Đổi workflow làm việc | `AGENTS.md` |
| Lưu thông tin user | `USER.md` |
| Lưu context dự án | `MEMORY.md` |
| Debug tool issues | `TOOLS.md` |
| Tạo hand từ scratch | `BOOTSTRAP.md` |

---

Sếp có muốn em demo tạo một hand mới với cấu hình custom không ạ? Hoặc sếp muốn tìm hiểu sâu hơn về cách các file này tương tác với LLM system prompt?
