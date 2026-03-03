# Changelog

All notable changes to the OpenFang Documentation will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.2] - 2026-03-04

### Added
- `customization/fix_alibaba_rate_limit.md`: Hướng dẫn và Script tự động giải phóng giới hạn Token/Cost của thiết lập nội bộ OpenFang, hỗ trợ gói Alibaba.
- Chuyển toàn bộ các file hướng dẫn custom cá nhân hóa vào thư mục `customization/` để dễ quản lý.

## [1.3.1] - 2026-03-04

### Added
- `openfang_update_monitor_setup.md`: Hướng dẫn chi tiết thiết lập tự động giám sát và push alert update của Github tới Telegram.
- `skill_deploy_best_practices.md`: Hệ thống hướng dẫn an toàn lưu trữ tuỳ biến của local khỏi bị ghi đè.
- Bộ tiện ích `scripts/apply_customizations.py`, `post_update.sh`, `post_update.bat` cho phép tự động apply lại toàn bộ Code Modifications đã tuỳ biến lên bản OpenFang cài đặt mới (9router, UI Add Edit Button).

## [1.3.0] - 2026-03-02

### Added
- `docker_deployment.md`: Comprehensive guide for deploying OpenFang using Docker and Docker Compose.
- `upgrade-macos.md`: Step-by-step instructions for upgrading OpenFang on macOS systems.

## [1.2.0] - 2026-03-02

### Added
- `muasamcong_workflows.md`: Detailed procurement monitoring and analysis workflows for muasamcong.mpi.gov.vn.

### Fixed
- Restored accidentally deleted documentation files (`CHANGELOG.md`, `VERSION`, `workflows.md`) from git history.
- Reconciled and recreated feature documentation for `add_edit_button.md` and `change_model.md`.

## [1.1.0] - 2026-03-02

### Added
- `alibaba-coding-plan.md`: Integration guide for Alibaba Cloud Coding Plan.
- `workflows.md`: Standard workflows for model switching and UI enhancements.
- `add_edit_button.md`: Documentation for Dashboard agent chip UI improvements.
- `change_model.md`: Comprehensive model switching instructions.

### Fixed
- OpenAIDriver configuration bug regarding custom base URLs (Documentation updated with workaround).

## [1.0.0] - 2026-03-01

### Added
- Initial release of OpenFang documentation.
- `openfang_overview.md`: Complete system overview and comparison with other frameworks.
- `9router_integration.md`: Detailed guide for adding custom LLM providers.
- `api.md`: Reference for API and MCP integration.
- `architecture.md`: High-level system design and security layers.
- `setup.md`: Installation and configuration guide.
- `user_guide.md`: Core features and autonomous "Hands" usage.
