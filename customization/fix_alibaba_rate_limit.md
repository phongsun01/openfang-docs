# Hướng dẫn gỡ bỏ giới hạn Rate Limit của OpenFang (Alibaba Coding Plan)

Lỗi `Resource quota exceeded: Agent <uuid> exceeded hourly cost quota: $1.0958 / $1.0000` hoặc lỗi `Token limit exceeded` khi sử dụng các gói trọn gói như Alibaba Cloud Lite Basic Plan xảy ra do cơ chế an toàn nội bộ của OpenFang tự động giới hạn 300,000 tokens/giờ hoặc $1.00/giờ đối với Agent `assistant` mặc định.

Do thông số này được nạp cứng dưới dạng nhị phân Bincode (MessagePack) vào cơ sở dữ liệu SQLite của OpenFang, cách duy nhất để xử lý triệt để mà không làm mất phiên làm việc gốc là trực tiếp ghi đè vào Database SQLite trong lúc OpenFang đã tắt.

## Cách chạy tập lệnh tự động (Auto-Fix Script)

Trên bất kỳ máy nào gặp lỗi tương tự, hãy copy toàn bộ đoạn mã Bash dưới đây, dán vào Terminal và bấm Enter. Tập lệnh này sẽ tự động:
1. Trích xuất một dự án Rust tạm thời.
2. Viết đoạn mã giải mã MessagePack và ghi đè giới hạn `max_llm_tokens_per_hour = 10000000` và `max_cost_per_hour_usd = 0.0`.
3. Tạm dừng OpenFang (`openfang stop`).
4. Chạy mã vá dữ liệu vào SQLite.
5. Khởi động lại OpenFang.

```bash
#!/bin/bash
set -e

echo "=> Thay đổi giới hạn (Quota) của OpenFang..."

# 1. Tạo thư mục build tạm
mkdir -p /tmp/openfang_fix_quota/src
cd /tmp/openfang_fix_quota

# 2. Tạo Cargo.toml
cat << 'EOF' > Cargo.toml
[package]
name = "fix_quota"
version = "0.1.0"
edition = "2021"

[dependencies]
openfang-types = { git = "https://github.com/RightNow-AI/openfang.git" }
rusqlite = { version = "0.31.0", features = ["bundled"] }
rmp-serde = "1.3.1"
shellexpand = "3.1.2"
EOF

# 3. Tạo src/main.rs
cat << 'EOF' > src/main.rs
use openfang_types::agent::AgentManifest;
use rusqlite::Connection;

fn main() {
    let db_path = shellexpand::tilde("~/.openfang/data/openfang.db").into_owned();
    let conn = Connection::open(db_path).expect("Failed to open DB");
    
    let mut stmt = conn.prepare("SELECT id, manifest FROM agents").unwrap();
    let agents: Vec<(String, Vec<u8>)> = stmt.query_map([], |row| {
        Ok((row.get(0)?, row.get(1)?))
    }).unwrap().map(|r| r.unwrap()).collect();

    for (id, blob) in agents {
        let manifest_res: Result<AgentManifest, _> = rmp_serde::from_slice(&blob);
        match manifest_res {
            Ok(mut manifest) => {
                let mut updated = false;
                if manifest.resources.max_llm_tokens_per_hour < 10000000 || manifest.resources.max_cost_per_hour_usd > 0.0 {
                    manifest.resources.max_llm_tokens_per_hour = 10000000;
                    manifest.resources.max_cost_per_hour_usd = 0.0;
                    manifest.resources.max_cost_per_day_usd = 0.0;
                    manifest.resources.max_cost_per_month_usd = 0.0;
                    updated = true;
                }
                
                if updated {
                    let new_blob = rmp_serde::to_vec_named(&manifest).expect("Failed to serialize manifest");
                    conn.execute("UPDATE agents SET manifest = ?1 WHERE id = ?2", rusqlite::params![new_blob, id]).unwrap();
                    println!("  [+] Đã vô hiệu hóa giới hạn Quota cho Agent: {} ({})", manifest.name, id);
                }
            },
            Err(e) => {
                println!("  [-] Không thể đọc Agent (có thể lệch version): {} - Lỗi: {}", id, e);
            }
        }
    }
}
EOF

# 4. Tắt OpenFang
echo "=> Đang tạm dừng tín trình OpenFang..."
openfang stop || true

# 5. Chạy bản vá
echo "=> Đang biên dịch và áp dụng bản vá SQLite (sẽ mất khoảng vài phút nếu chạy lần đầu)..."
cargo run --release

# 6. Mở lại OpenFang
echo "=> Khởi động lại OpenFang..."
openfang start &

echo "================================================="
echo "✅ HOÀN TẤT VÁ LỖI RATE LIMIT CHO ALIBABA PLAN ✅"
echo "================================================="
```

*Lưu ý: Yêu cầu hệ thống phải cài sẵn `rust` và `cargo` để có thể biên dịch đoạn script trên.*
