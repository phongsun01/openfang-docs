# OpenFang Post-Update Configuration Applier for Windows
Write-Host "🚀 Bat dau apply OpenFang Custom Modifications tren tro trinh Windows..." -ForegroundColor Cyan

$REPO_DIR = Split-Path -Parent $PSScriptRoot

$FILE_TYPES_MODEL_CATALOG = Join-Path $REPO_DIR "crates\openfang-types\Write-Host src\model_catalog.rs"
$FILE_RUNTIME_MODEL_CATALOG = Join-Path $REPO_DIR "crates\openfang-runtime\src\model_catalog.rs"
$FILE_DRIVERS = Join-Path $REPO_DIR "crates\openfang-runtime\src\drivers\mod.rs"
$FILE_HTML = Join-Path $REPO_DIR "crates\openfang-api\static\index_body.html"

# Function to read, replace by regex and write file
function Apply-Patch {
    param (
        [string]$FilePath,
        [string]$RegexSearch,
        [string]$Replacement,
        [string]$CheckString,
        [string]$SuccessMessage
    )
    if (Test-Path $FilePath) {
        $content = Get-Content -Raw -Encoding UTF8 $FilePath
        if ($content -notmatch [regex]::Escape($CheckString)) {
            $content = $content -replace $RegexSearch, $Replacement
            Set-Content -Path $FilePath -Value $content -Encoding UTF8 -NoNewline
            Write-Host "  ✅ $SuccessMessage" -ForegroundColor Green
        } else {
            Write-Host "  ⏭️  Da ton tai: $CheckString" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ❌ Lỗi: Khong tim thay file $FilePath" -ForegroundColor Red
    }
}

Write-Host "⚙️ 1/3 Apply 9router integration..." -ForegroundColor Cyan

# 1.1 Thêm URL
Apply-Patch -FilePath $FILE_TYPES_MODEL_CATALOG `
            -RegexSearch 'pub const REPLICATE_BASE_URL: \&str = "https://api.replicate.com/v1";' `
            -Replacement "pub const REPLICATE_BASE_URL: &str = `"https://api.replicate.com/v1`";`npub const NINEROUTER_BASE_URL: &str = `"http://127.0.0.1:20128/v1`";" `
            -CheckString "NINEROUTER_BASE_URL" `
            -SuccessMessage "Thêm NINEROUTER_BASE_URL."

# 1.2 Thêm 9router Runtime Enum 
Apply-Patch -FilePath $FILE_RUNTIME_MODEL_CATALOG `
            -RegexSearch 'ZHIPU_CODING_BASE_URL,' `
            -Replacement 'ZHIPU_CODING_BASE_URL, NINEROUTER_BASE_URL,' `
            -CheckString 'ZHIPU_CODING_BASE_URL, NINEROUTER_BASE_URL' `
            -SuccessMessage "Nhập NINEROUTER_BASE_URL import."

Apply-Patch -FilePath $FILE_RUNTIME_MODEL_CATALOG `
            -RegexSearch '(?m)^(\s*// ── GitHub Copilot ──)' `
            -Replacement "        ProviderInfo {`n            id: `"9router`".into(),`n            display_name: `"9router`".into(),`n            api_key_env: `"NINEROUTER_API_KEY`".into(),`n            base_url: NINEROUTER_BASE_URL.into(),`n            key_required: true,`n            auth_status: AuthStatus::Missing,`n            model_count: 0,`n        },`n`$1" `
            -CheckString 'id: "9router".into()' `
            -SuccessMessage "Thêm provider 9router."

Apply-Patch -FilePath $FILE_RUNTIME_MODEL_CATALOG `
            -RegexSearch '(?m)^(\s*ModelCatalogEntry \{\s*id: `"claude-opus-4-6`")' `
            -Replacement "        ModelCatalogEntry {`n            id: `"openfang-bombo`".into(),`n            display_name: `"OpenFang Bombo (9router)`".into(),`n            provider: `"9router`".into(),`n            tier: ModelTier::Smart,`n            context_window: 128_000,`n            max_output_tokens: 8192,`n            input_cost_per_m: 0.0,`n            output_cost_per_m: 0.0,`n            supports_tools: true,`n            supports_vision: true,`n            supports_streaming: true,`n            aliases: vec![],`n        },`n`$1" `
            -CheckString 'id: "openfang-bombo".into()' `
            -SuccessMessage "Thêm model openfang-bombo."

# 1.3 Thêm 9router vao Drivers
Apply-Patch -FilePath $FILE_DRIVERS `
            -RegexSearch 'ZHIPU_CODING_BASE_URL,' `
            -Replacement 'ZHIPU_CODING_BASE_URL, NINEROUTER_BASE_URL,' `
            -CheckString 'ZHIPU_CODING_BASE_URL, NINEROUTER_BASE_URL' `
            -SuccessMessage "Them NINEROUTER import trong Drivers."

Apply-Patch -FilePath $FILE_DRIVERS `
            -RegexSearch '(?m)^(\s*`"github-copilot`" \| `"copilot`")' `
            -Replacement "        `"9router`" => Some(ProviderDefaults {`n            base_url: NINEROUTER_BASE_URL,`n            api_key_env: `"NINEROUTER_API_KEY`",`n            key_required: true,`n        }),`n`$1" `
            -CheckString '9router" => Some(ProviderDefaults' `
            -SuccessMessage "Map 9router Driver Defaults."

Apply-Patch -FilePath $FILE_DRIVERS `
            -RegexSearch '(?m)^(\s*`"claude-code`",)' `
            -Replacement "`$1`n        `"9router`"," `
            -CheckString '"9router",' `
            -SuccessMessage "Thêm 9router vào known_providers."

Write-Host "⚙️ 2/3 Apply Add Edit Agent UI Button..." -ForegroundColor Cyan

# Backup HTML
if (Test-Path $FILE_HTML) {
    if (-Not (Test-Path "$FILE_HTML.bak")) {
        Copy-Item $FILE_HTML "$FILE_HTML.bak"
    }
}

Apply-Patch -FilePath $FILE_HTML `
            -RegexSearch '(?m)^(\s*<option value="openai">OpenAI</option>)' `
            -Replacement "`$1`n                          <option value=`"9router`">9router</option>" `
            -CheckString '<option value="9router">9router</option>' `
            -SuccessMessage "Inject 9router Select box UI."

Apply-Patch -FilePath $FILE_HTML `
            -RegexSearch '(?m)^(\s*<div class="agent-chip-content">)' `
            -Replacement "`$1`n              <button class=`"btn btn-ghost btn-sm`"`n                      @click.stop=`"showDetail(agent)`"`n                      title=`"Edit Agent`"`n                      style=`"padding: 4px; border-radius: 50%; width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; margin-left: auto;`">`n                <svg width=`"14`" height=`"14`" viewBox=`"0 0 24 24`" fill=`"none`" stroke=`"currentColor`" stroke-width=`"2`">`n                  <path d=`"M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7`" />`n                  <path d=`"M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z`" />`n                </svg>`n              </button>" `
            -CheckString '@click.stop="showDetail(agent)"' `
            -SuccessMessage "Inject Edit button vào agent chips."

Write-Host "=========================================" -ForegroundColor Green
Write-Host "✅ HOÀN TẤT PS1 SCRIPT." -ForegroundColor Green
Write-Host "Compile lai ung dung Native (cargo build --release) de ap dung!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
