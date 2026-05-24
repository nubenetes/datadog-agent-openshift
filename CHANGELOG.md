# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-24

### Added
- **Production-Ready Datadog on OpenShift**: Initial stable release featuring comprehensive deployment strategies.
- **Operator-Led Lifecycle (Solution 2)**: Full support for Datadog Operator and OLM-based deployments, including custom Security Context Constraints (SCC).
- **Legacy Helm Support (Solution 1)**: Verified Helm v3 templates for flexible agent configuration.
- **APM & Library Injection**: Java Spring demo application demonstrating transparent APM instrumentation via Datadog Admission Controller.
- **AI-Enhanced Documentation**: Integrated technical blueprints and video summaries for accelerated onboarding.

### Security
- **Data Anonymization**: Global sweep of manifests and documentation to sanitize organizational identifiers and network data.
- **Asset Hardening**: Automated metadata stripping for all architectural image resources.

### Fixed
- **Performance Optimization**: Implemented collapsible Mermaid diagrams in READMEs to improve documentation responsiveness.
