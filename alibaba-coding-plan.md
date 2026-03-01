# Alibaba Coding Plan Integration Guide

Successfully integrated the Alibaba Cloud Coding Plan (Lite/Pro) with OpenFang.

## Key Changes Made

### 1. Configuration (`~/.openfang/config.toml`)
Updated the `[default_model]` section to use `qwen3.5-plus` and explicitly set the `base_url` for the Coding Plan Singapore endpoint.

```toml
[default_model]
api_key_env = "DASHSCOPE_API_KEY"
base_url = "https://coding-intl.dashscope.aliyuncs.com/v1"
model = "qwen3.5-plus"
provider = "qwen"

[provider_urls]
qwen = "https://coding-intl.dashscope.aliyuncs.com/v1"
```

> [!NOTE]
> Explicitly setting `base_url` in `[default_model]` was necessary to bypass an OpenFang kernel bug where global provider URL overrides were ignored during driver resolution.

### 2. Environment Variables (`~/.openfang/.env`)
Added the "Exclusive API Key" (sk-sp-...) refreshed by the user.

```bash
DASHSCOPE_API_KEY=sk-sp-...
```

### 3. Agent Configurations
Updated all agents to use the `qwen` provider and `qwen3.5-plus` model by default.

## Verification Results

### Connection Test
Successfully tested the `sk-sp-` key against the Coding Plan endpoint using `curl`:
- **Endpoint**: `https://coding-intl.dashscope.aliyuncs.com/v1`
- **Result**: `200 OK` (Message received from Qwen 3.5 Plus)

### End-to-End Agent Test
Verified through the OpenFang API:
- **Agent**: `assistant`
- **Model**: `qwen3.5-plus`
- **Response**: "Hi Sếp! 👋 How can I help you today?"

## Known Issues Resolved
- **invalid_api_key**: Fixed by ensuring the correct subset of the API key was used and refreshing it.
- **Endpoint Mismatch**: Fixed by setting the dedicated Coding Plan Singapore endpoint.
- **Kernel URL Bypass**: Bypassed by moving the URL override into the `[default_model]` section.
- **Local Quota Exceeded**: If you see "Resource quota exceeded: Token limit exceeded", increase the `max_llm_tokens_per_hour` in your `~/.openfang/agents/<agent_name>/agent.toml` files. OpenFang defaults for small models (like 300k) are easily hit by the high throughput of the Alibaba Coding Plan.
