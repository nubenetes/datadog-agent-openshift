# 🛠️ Project Gemini Instructions: Datadog on OpenShift

This file provides architectural context, engineering standards, and workflows for the Datadog on OpenShift examples project.

## 🏗️ Architectural Overview
The project focuses on deploying the Datadog Agent on OpenShift 4.x using two main methods:
1.  **Solution 2 (Recommended)**: Operator-led lifecycle using the Datadog Operator and OLM.
    -   Primary Manifest: `solution-2-operator/datadog-agent-on-openshift.yaml`
    -   Security: `solution-2-operator/scc.yaml` (Security Context Constraints)
2.  **Solution 1 (Legacy)**: Helm-based deployment.
    -   Primary Manifest: `solution-1-helm-chart/values.yaml`

## 🏷️ Unified Tagging & Discovery
All telemetry MUST follow the unified tagging schema:
-   `tags.datadoghq.com/service`: Application name.
-   `tags.datadoghq.com/env`: Environment (`prod`, `dev`, etc.).
-   `tags.datadoghq.com/version`: Version identifier.

## 🛡️ Security Standards (OpenShift Specific)
-   **SCCs**: Custom Security Context Constraints are required for the Node Agent to access host-level data (eBPF, logs).
-   **Admission Controller**: Used for transparent library injection (APM). Mode `hostip` is preferred for OpenShift.

## 🔄 Common Workflows
-   **Troubleshooting Logs**: Check `scc.yaml` permissions and `containerExclude` filters.
-   **APM Injection**: Verify `admission.datadoghq.com/enabled` label on application pods.
-   **Deployment**: Prefer `solution-2-operator` for production-grade setups.

## 📁 Directory Structure
-   `apm-poc/`: Java Spring demo application for APM testing.
-   `solution-1-helm-chart/`: Helm v3 templates.
-   `solution-2-operator/`: Datadog Operator and OLM manifests.
-   `images/`: Architecture and UI documentation.

## 🛠️ Tooling & Validation
-   Use `oc` (OpenShift CLI) for cluster interactions.
-   Validate YAML manifests against `.yamllint` if available.
-   Refer to the Troubleshooting Decision Tree in `README.md` for diagnostic steps.


- **Collapsible Architecture Diagrams**: For complex architectural visualizations (Mermaid diagrams), the documentation MUST use the HTML5 `<details>` and `<summary>` tags. This optimizes page load performance and maintains visual density in high-content technical guides like README.md.
