# How to Change the LLM Model in OpenFang

This guide explains how to switch the model for an agent, specifically focusing on migrating to the Alibaba Cloud Coding Plan.

## 1. Global Default Configuration

You can set the default model and provider for all new agents in `~/.openfang/config.toml`.

```toml
[default_model]
api_key_env = "DASHSCOPE_API_KEY"
base_url = "https://coding-intl.dashscope.aliyuncs.com/v1"
model = "qwen3.5-plus"
provider = "qwen"
```

## 2. Using the Dashboard (Recommended)

Thanks to the new **Edit** button, you can change the model for existing agents through the web interface:

1.  Go to the **Dashboard** -> **Agents**.
2.  Click the **Pencil Icon** (Edit) on an agent card.
3.  Go to the **Config** tab.
4.  Update the **Model** field (e.g., `qwen3.5-plus`).
5.  Update the **Provider** field (e.g., `qwen`).
6.  Click **Save Config**.

## 3. Manual Configuration (Advanced)

If you prefer editing files directly, you can modify the `agent.toml` file for a specific agent.

### Example: `~/.openfang/agents/assistant/agent.toml`
```toml
[model]
provider = "qwen"
model = "qwen3.5-plus"
api_key_env = "DASHSCOPE_API_KEY"
```

## 4. Environment Variables

Ensure your API key is correctly set in `~/.openfang/.env`. For Alibaba Coding Plan, use the **Exclusive API Key** (`sk-sp-...`).

```bash
DASHSCOPE_API_KEY=sk-sp-xxxx...
```

## 5. Troubleshooting Endpoint Issues

If your provider uses a custom endpoint (like Alibaba's Coding Plan Singapore region), ensure it is configured in `config.toml`:

```toml
[provider_urls]
qwen = "https://coding-intl.dashscope.aliyuncs.com/v1"
```

> [!TIP]
> If the kernel ignores the provider override, you may need to explicitly set `base_url` within the agent's `[model]` section or the global `[default_model]` section.
