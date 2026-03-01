# OpenFang — Tổng quan

OpenFang là hệ điều hành dành cho các agent tự trị mã nguồn mở, được xây dựng bằng Rust với 137K dòng code, 14 crates và hơn 1.767 bài kiểm tra, không có cảnh báo Clippy nào. ([GitHub](https://github.com/RightNow-AI/openfang/blob/main/README.md)) Toàn bộ hệ thống biên dịch thành một file nhị phân duy nhất khoảng 32MB, dễ cài đặt và chạy các agent hoạt động độc lập 24/7.

---

## Giới thiệu OpenFang

OpenFang không phải là framework chatbot hay wrapper Python quanh LLM, mà là hệ điều hành đầy đủ cho các agent tự trị, được xây dựng từ đầu bằng Rust. Các agent chạy theo lịch trình, xây dựng đồ thị kiến thức, giám sát mục tiêu, tạo lead, quản lý mạng xã hội và báo cáo kết quả lên dashboard mà không cần bạn phải prompt thủ công.

---

## Cài đặt nhanh

Chạy lệnh sau trên macOS/Linux để cài đặt:

```bash
curl -fsSL https://openfang.sh/install | sh
```

Sau đó:

```bash
openfang init    # Khởi tạo
openfang start   # Chạy daemon — Dashboard tại http://localhost:4200
```

Trên Windows, sử dụng PowerShell tương tự.

---

## Hands — Các gói khả năng tự trị

Hands là sáng tạo cốt lõi của OpenFang: các gói khả năng tự trị chạy độc lập theo lịch, **không cần prompt**. Mỗi Hand bao gồm:

- `HAND.toml` — manifest cấu hình
- System prompt đa giai đoạn
- `SKILL.md` — mô tả kỹ năng
- Guardrails — yêu cầu phê duyệt cho hành động nhạy cảm

**Kích hoạt ví dụ:**
```bash
openfang hand activate researcher
```

| Hand       | Chức năng chính |
|------------|-----------------|
| **Clip**       | Tải YouTube, cắt shorts với caption/thumbnail, đăng Telegram/WhatsApp. |
| **Lead**       | Tìm prospect theo ICP, làm giàu dữ liệu, chấm điểm và xuất CSV/JSON. |
| **Collector**  | Giám sát OSINT (công ty/người/chủ đề), xây dựng knowledge graph. |
| **Predictor**  | Dự báo siêu chính xác với confidence intervals và theo dõi độ chính xác. |
| **Researcher** | Nghiên cứu sâu, đánh giá nguồn bằng CRAAP, báo cáo có trích dẫn APA. |
| **Twitter**    | Quản lý tài khoản X: tạo nội dung, lên lịch, phản hồi mentions. |
| **Browser**    | Tự động hóa web với Playwright, yêu cầu phê duyệt mua hàng. |

---

## So sánh với các framework khác

OpenFang vượt trội về tốc độ cold start (<200ms), bộ nhớ nhàn rỗi (40MB), kích thước cài đặt (32MB) và 16 lớp bảo mật so với các framework khác. Hỗ trợ **40 channel adapters** (Telegram, Discord, Zalo...), **27 LLM providers** (Anthropic, Groq, Ollama...) và **53 tools** tích hợp.

| Tiêu chí          | OpenFang | OpenClaw   | ZeroClaw |
|-------------------|----------|------------|----------|
| Ngôn ngữ          | Rust     | TypeScript | Rust     |
| Bảo mật           | 16 lớp   | 3 lớp      | 6 lớp    |
| Channel Adapters  | 40       | 13         | 15       |
| Kích thước cài đặt| ~32MB    | ~500MB     | ~8.8MB   |

---

## 16 hệ thống bảo mật

OpenFang áp dụng bảo mật sâu với các cơ chế độc lập và kiểm tra được:

- WASM sandbox
- Merkle hash-chain audit trail
- Taint tracking
- Ed25519 manifest signing
- SSRF protection
- Prompt injection scanner
- GCRA rate limiter
- ... và nhiều lớp khác

---

## Kiến trúc và tính năng

Gồm **14 crates Rust**:

| Crate | Vai trò |
|-------|---------|
| `openfang-kernel` | Lập lịch, RBAC, orchestration |
| `openfang-runtime` | LLM drivers, tool execution |
| `openfang-api` | 140+ endpoints OpenAI-compatible |
| `openfang-memory` | SQLite + vector memory |
| `openfang-hands` | Autonomous hands (Clip, Lead...) |
| `openfang-channels` | 40 adapters (bao gồm Zalo) |

**Di chuyển từ OpenClaw:**
```bash
openfang migrate --from openclaw
```

---

## Thông tin phiên bản

- **Phiên bản:** v0.1.0 (tháng 2/2026)
- **License:** MIT
- **Trạng thái:** Đang phát triển nhanh — có thể có breaking changes đến v1.0

> Để triển khai trên Mac Mini M4 24GB, chỉ cần chạy install script — binary nhẹ (~32MB), hiệu suất cao nhờ Rust.
