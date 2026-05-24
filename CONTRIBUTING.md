# Contributing Guidelines

> [!IMPORTANT]
> **Spanish Version / Versión en Español**:
> Este repositorio cuenta con una versión en español redactada manualmente: [CONTRIBUTING-Spanish.md](CONTRIBUTING-Spanish.md).
>
> **English Version**:
> This English documentation (`CONTRIBUTING.md`) is the primary version for guidelines.

---

## How to Contribute

1.  **Fork the repository** to your own GitHub account.
2.  **Create a new branch** for your feature or bug fix (\`git checkout -b feature/your-feature-name\`).
3.  **Make your changes**, ensuring they align with the project's architecture and coding standards.
4.  **Test your changes** locally if applicable.
5.  **Commit your changes** with clear and descriptive commit messages.
6.  **Push your branch** to your fork (\`git push origin feature/your-feature-name\`).
7.  **Open a Pull Request (PR)** against the \`develop\` branch of this repository.

## Coding Standards

-   **YAML:** Please ensure all YAML files are properly formatted. We use \`yamllint\` in our CI pipeline.
-   **Documentation:** If your change introduces new features or alters existing behavior, please update \`README.md\` and \`ENGINEER.md\` accordingly.
-   **Anonymization:** Do not include any sensitive company data, IPs, passwords, or personal emails in your commits.

## Pull Request Process

-   Ensure your PR targets the \`develop\` branch, not \`main\`.
-   Provide a clear description of what the PR solves or adds.
-   Wait for a maintainer to review and approve your PR.

Thank you for helping improve the project!
