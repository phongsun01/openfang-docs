import os
import re

def patch_file(filepath, pattern, replacement, check_str, success_msg):
    if not os.path.exists(filepath):
        print(f"  ❌ Lỗi: Không tìm thấy file {filepath}")
        return
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    if check_str in content:
        print(f"  ⏭️  Đã tồn tại (Bỏ qua): {success_msg}")
        return
        
    new_content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"  ✅ {success_msg}")
    else:
        print(f"  ⚠️ Warning: Không tìm thấy đoạn code cần inject cho {success_msg}")

def main():
    repo_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    print(f"📂 Thư mục Repo: {repo_dir}")
    
    mc_types = os.path.join(repo_dir, "crates", "openfang-types", "src", "model_catalog.rs")
    mc_rt = os.path.join(repo_dir, "crates", "openfang-runtime", "src", "model_catalog.rs")
    drv = os.path.join(repo_dir, "crates", "openfang-runtime", "src", "drivers", "mod.rs")
    html = os.path.join(repo_dir, "crates", "openfang-api", "static", "index_body.html")

    print("\n⚙️  1/2 Apply 9router integration...")
    
    # model_catalog.rs (types)
    patch_file(mc_types, 
        r'(pub const REPLICATE_BASE_URL: &str = "[^"]+";)', 
        r'\1\npub const NINEROUTER_BASE_URL: &str = "http://127.0.0.1:20128/v1";', 
        'NINEROUTER_BASE_URL', "Thêm NINEROUTER_BASE_URL.")

    # model_catalog.rs (runtime)
    patch_file(mc_rt, r'ZHIPU_CODING_BASE_URL,', r'ZHIPU_CODING_BASE_URL, NINEROUTER_BASE_URL,', 'ZHIPU_CODING_BASE_URL, NINEROUTER_BASE_URL', "Import NINEROUTER_BASE_URL")
    
    patch_file(mc_rt, r'(^ {8}// ── GitHub Copilot ──)', r'''        ProviderInfo {
            id: "9router".into(),
            display_name: "9router".into(),
            api_key_env: "NINEROUTER_API_KEY".into(),
            base_url: NINEROUTER_BASE_URL.into(),
            key_required: true,
            auth_status: AuthStatus::Missing,
            model_count: 0,
        },
\1''', 'id: "9router".into()', 'Thêm provider 9router.')

    patch_file(mc_rt, r'(^ {8}ModelCatalogEntry \{\n {12}id: "claude-opus-4-6".into\(\),)', r'''        ModelCatalogEntry {
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
\1''', 'id: "openfang-bombo".into()', 'Thêm model openfang-bombo.')

    # drivers (mod.rs)
    patch_file(drv, r'ZHIPU_CODING_BASE_URL,', r'ZHIPU_CODING_BASE_URL, NINEROUTER_BASE_URL,', 'ZHIPU_CODING_BASE_URL, NINEROUTER_BASE_URL', "Import NINEROUTER trong Drivers.")
    patch_file(drv, r'(^ {8}"github-copilot" \| "copilot")', r'''        "9router" => Some(ProviderDefaults {
            base_url: NINEROUTER_BASE_URL,
            api_key_env: "NINEROUTER_API_KEY",
            key_required: true,
        }),
\1''', '9router" => Some(ProviderDefaults', 'Thêm mapping 9router Driver.')

    patch_file(drv, r'(^ {8}"claude-code",)', r'\1\n        "9router",', '"9router",\n', 'Thêm 9router vào known_providers.')


    print("\n⚙️  2/2 Apply Add/Edit Agent Button UI...")
    
    # Backup
    import shutil
    if os.path.exists(html) and not os.path.exists(html + ".bak"):
        shutil.copy2(html, html + ".bak")
        print("  ✅ Tạo backup index_body.html.bak")

    patch_file(html, r'(^ {26}<option value="openai">OpenAI</option>)', r'\1\n                          <option value="9router">9router</option>', 'value="9router"', 'Thêm select box 9router UI.')

    patch_file(html, r'(^ {14}<div class="agent-chip-content">)', r'''\1
              <button class="btn btn-ghost btn-sm"
                      @click.stop="showDetail(agent)"
                      title="Edit Agent"
                      style="padding: 4px; border-radius: 50%; width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; margin-left: auto;">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                  <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                </svg>
              </button>''', '@click.stop="showDetail(agent)"', 'Thêm UI nút Edit vào card agent.')

    print("\n=========================================")
    print("✅ Hoàn tất cấu hình. Vui lòng cargo build --release để áp dụng lại.")

if __name__ == "__main__":
    main()
