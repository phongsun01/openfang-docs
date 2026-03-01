# Tích hợp 9router vào OpenFang

Hướng dẫn này mô tả **toàn bộ các thay đổi cần thực hiện** để thêm `9router` như một provider LLM chính thức vào OpenFang, bao gồm backend (Rust), cấu hình agent, và frontend Dashboard.

---

## Tổng quan

9router là một OpenAI-compatible LLM endpoint chạy local (mặc định tại `http://127.0.0.1:20128/v1`). OpenFang hỗ trợ bất kỳ endpoint nào tương thích OpenAI — nhưng để nó xuất hiện trong **Dashboard Settings** và được nhận diện đúng tên, cần thêm nó vào model catalog.

---

## 1. Backend — Codebase Rust (repo)

### 1.1 Thêm hằng số URL

**File:** `crates/openfang-types/src/model_catalog.rs`

```rust
// Thêm sau dòng REPLICATE_BASE_URL
pub const NINEROUTER_BASE_URL: &str = "http://127.0.0.1:20128/v1";
```

### 1.2 Thêm 9router vào Provider Catalog

**File:** `crates/openfang-runtime/src/model_catalog.rs`

**a) Import thêm constant:**
```rust
use openfang_types::model_catalog::{
    // ... các URL hiện có ...,
    NINEROUTER_BASE_URL,
    // ...
};
```

**b) Thêm ProviderInfo vào hàm `builtin_providers()`:**
```rust
ProviderInfo {
    id: "9router".into(),
    display_name: "9router".into(),
    api_key_env: "NINEROUTER_API_KEY".into(),
    base_url: NINEROUTER_BASE_URL.into(),
    key_required: true,
    auth_status: AuthStatus::Missing,
    model_count: 0,
},
```

**c) Thêm model vào hàm `builtin_models()`:**
```rust
ModelCatalogEntry {
    id: "openfang-bombo".into(),
    display_name: "OpenFang Bombo (9router)".into(),
    provider: "9router".into(),
    tier: ModelTier::Smart,
    context_window: 128_000,
    max_output_tokens: 8192,
    input_cost_per_m: 0.0,
    output_cost_per_m: 0.0,
    supports_tools: true,
    supports_vision: true,
    supports_streaming: true,
    aliases: vec![],
},
```

### 1.3 Thêm 9router vào Driver Registry

**File:** `crates/openfang-runtime/src/drivers/mod.rs`

**a) Import:**
```rust
use openfang_types::model_catalog::{
    // ... ,
    NINEROUTER_BASE_URL,
};
```

**b) Thêm vào hàm `provider_defaults()`:**
```rust
"9router" => Some(ProviderDefaults {
    base_url: NINEROUTER_BASE_URL,
    api_key_env: "NINEROUTER_API_KEY",
    key_required: true,
}),
```

**c) Thêm vào hàm `known_providers()`:**
```rust
"9router",
```

### 1.4 Build lại

```bash
cd /path/to/openfang/repo
cargo build --workspace
```

---

## 2. Frontend Dashboard — UI

**File:** `crates/openfang-api/static/index_body.html`

Tìm dropdown `<select>` của provider trong wizard spawn agent và thêm option 9router:

```html
<option value="9router">9router</option>
```

> **Lưu ý:** Phần Settings > LLM Providers hiển thị providers động từ API `/api/providers`, không cần sửa gì thêm — sau khi build xong, 9router sẽ tự xuất hiện ở đó.

---

## 3. Cấu hình người dùng

### 3.1 API Key

**File:** `~/.openfang/.env`

```env
NINEROUTER_API_KEY=sk-<Key>
```

### 3.2 Default Model

**File:** `~/.openfang/config.toml`

```toml
[default_model]
provider = "9router"
model = "openfang-bombo"
api_key_env = "NINEROUTER_API_KEY"
```

### 3.3 Agent

Nếu agent đã tồn tại (ví dụ `assistant`), cần cập nhật file `~/.openfang/agents/assistant/agent.toml`:

```toml
[model]
provider = "9router"
model = "openfang-bombo"
```

Để thay đổi tất cả agents cùng lúc:

```bash
python3 -c '
import os, glob
for f in glob.glob(os.path.expanduser("~/.openfang/agents/*/agent.toml")):
    c = open(f).read()
    c = c.replace("provider = \"groq\"", "provider = \"9router\"")
    c = c.replace("model = \"llama-3.3-70b-versatile\"", "model = \"openfang-bombo\"")
    open(f, "w").write(c)
'
```

---

## 4. Reset trạng thái agent trong SQLite

> **Quan trọng:** OpenFang lưu manifest agent vào SQLite (`~/.openfang/data/openfang.db`). Khi restart, nó **ưu tiên đọc từ DB** trước `agent.toml`. Vì vậy, sau khi thay đổi `agent.toml`, phải xóa DB để agent reload đúng config mới.

```bash
# Dừng daemon trước
sqlite3 ~/.openfang/data/openfang.db "DELETE FROM agents"
```

---

## 5. Khởi động lại

```bash
cargo run --bin openfang -- start
```

Daemon log phải hiển thị:
```
✔ Kernel booted (9router/openfang-bombo)
  Provider:    9router
  Model:       openfang-bombo
```

**Và log khi agent được tạo mới (fresh):**
```
Spawning agent agent=assistant id=...
```
(Không phải `Restored agent` — nếu thấy `Restored` là vẫn đọc từ DB cũ)

---

## 6. Kiểm tra trên Dashboard

Mở `http://127.0.0.1:4200/#settings` → tab **Providers** → Sẽ thấy card **9router** xuất hiện với trạng thái `configured` (nếu API key đã được set đúng trong `.env`).

---

## Tóm tắt file đã thay đổi

| File | Thay đổi |
|------|----------|
| `crates/openfang-types/src/model_catalog.rs` | Thêm `NINEROUTER_BASE_URL` |
| `crates/openfang-runtime/src/model_catalog.rs` | Thêm `ProviderInfo` + `ModelCatalogEntry` cho 9router |
| `crates/openfang-runtime/src/drivers/mod.rs` | Thêm `provider_defaults("9router")` + known providers |
| `crates/openfang-api/static/index_body.html` | Thêm option `9router` trong dropdown spawn agent |
| `~/.openfang/config.toml` | Set `[default_model]` = 9router |
| `~/.openfang/.env` | Set `NINEROUTER_API_KEY` |
| `~/.openfang/agents/*/agent.toml` | Thay `provider = "groq"` → `"9router"` |
| `~/.openfang/data/openfang.db` | Xóa bảng `agents` để reset state |
