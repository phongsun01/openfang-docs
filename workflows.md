# OpenFang Workflows

Professional workflows for common development tasks.

## 1. Alibaba Coding Plan Integration
Standard workflow for connecting to Alibaba's specialized coding endpoints.

1. **Get Key**: Obtain `sk-sp-` key from Model Studio.
2. **Set Endpoint**: Use `https://coding-intl.dashscope.aliyuncs.com/v1` for Singapore.
3. **Configure**: Update `config.toml` default model section with the `base_url`.
4. **Test**: Run `curl` to verify authentication.

## 2. Model Switching
How to change providers and models across the system.

1. **Update Config**: Modify `[default_model]` in `~/.openfang/config.toml`.
2. **Propagate**: Update all agent files in `~/.openfang/agents/`.
3. **Restart**: Cycle the daemon.

## 3. UI Enhancements
Guidelines for improving the OpenFang Dashboard components.

- **Agent Chips**: Added 'Edit' button to trigger immediate TOML editing.
- **Workflow Triggers**: Integration for manual and scheduled runs.
