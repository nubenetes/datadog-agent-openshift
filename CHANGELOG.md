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

## [1.0.0-rc.5] - 2026-05-22

### Security
- **Data Anonymization**: Performed a comprehensive sweep to replace internal tenant IDs, private IP addresses, and organizational identifiers with generic placeholders across all documentation and manifests.
- **Metadata Sanitization**: Purged all EXIF and proprietary metadata from architectural image assets in the `images/` directory using `exiftool`.

## [1.0.0-rc.4] - 2026-05-22

## [1.0.0-rc.3] - 2026-05-22

### Changed
- **Branding Synchronization**: Synchronized release version with the V2 Portal header and UI optimization.

## [1.0.0-rc.2] - 2026-05-22

## [1.0.0-rc.2] - 2026-05-22

### Changed
- **Release Synchronization**: Bumping version to maintain parity with the V2 Portal architectural updates.


## [1.0.0-rc.1] - 2026-05-22

### Added
- **Initial Engineering Documentation**: Consolidated HLD/LLD architecture diagrams and technical procedures for Datadog on OpenShift.
- **Solution 2 (Operator)**: Added OLM manifests and DatadogAgent CRD for production-grade deployments.
- **Solution 1 (Helm)**: Included legacy Helm chart values and Security Context Constraints (SCC).
- **APM Proof of Concept**: Added Java Spring demo application with both manual and automatic library injection examples.
- **AI-Generated Summaries**: Integrated NotebookLM video and presentation resources for rapid onboarding.

### Fixed
- **Documentation Rendering**: Optimized `README.md` by wrapping complex Mermaid diagrams in collapsible `<details>` blocks to improve page load performance and visual density.
- **Security Hardening**: Anonymized sensitive project metadata and stripped EXIF data from architectural images.
