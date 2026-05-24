# Template Files

> [!IMPORTANT]
> **Spanish Version / Versión en Español**:
> Este repositorio cuenta con una versión original en español redactada manualmente sin el uso de IA: [README-Spanish.md](README-Spanish.md).
>
> **English Version**:
> This English documentation (`README.md`) is a translation of the original Spanish version.

---

1. [Datadog Operator Helm Files](datadog-operator-helm-chart/README.md)
2. [values-experimental.yaml](values-experimental.yaml): 
    - My own experimental file with custom settings like ntp
3. [values-with-lib-conf.yaml (**not recommended**)](values-with-lib-conf.yaml): 
    - Values file with lib configuration. 
    - Reference: https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-admission-controller/
    - Origin file: https://github.com/DataDog/springblog/blob/main/k8s/depl-with-lib-conf.yaml
4. [values-with-lib-inj.yaml (**use this one**)](values-with-lib-inj.yaml): 
    - Values file with lib injection. 
    - Reference: https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-admission-controller/
    - Origin file: https://github.com/DataDog/springblog/blob/main/k8s/depl-with-lib-inj.yaml
