# Instrumenting a Spring Boot application with Datadog

> [!IMPORTANT]
> **Spanish Version / Versión en Español**:
> Este repositorio cuenta con una versión original en español redactada manualmente sin el uso de IA: [README-Spanish.md](README-Spanish.md).
>
> **English Version**:
> This English documentation (`README.md`) is a translation of the original Spanish version.

---

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [PoC with manually injected libraries configuration (not recommended)](#poc-with-manually-injected-libraries-configuration-not-recommended)
4. [PoC with automatic library injection (recommended)](#poc-with-automatic-library-injection-recommended)
5. [Testing the application with curl](#testing-the-application-with-curl)
6. [Screenshots](#screenshots)
7. [References](#references)

## Introduction

[This is the demo application](https://github.com/DataDog/springblog) referenced in [this Datadog document](https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-admission-controller/), used as a proof of concept to validate a correct Datadog APM configuration on OpenShift.

The log configuration with ```dd.trace_id``` and ```dd.span_id```[^1] is available in an [application.yml](https://github.com/DataDog/springblog/blob/main/demo-app/src/main/resources/application.yml) corresponding to [spring boot logging configuration](https://howtodoinjava.com/spring-boot/configure-logging-application-yml/):

```yaml
logging:
  level:
    root: info
    org.springframework.web: INFO
  pattern:
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %X{dd.trace_id} %X{dd.span_id} - %msg%n"
#    file: "%d{yyyy-MM-dd HH:mm:ss} %magenta([%thread]) %highlight(%-5level) %yellow(%logger{36}) - %X{dd.trace_id} %X{dd.span_id} - %msg%n"
#    console: "%d{yyyy-MM-dd HH:mm:ss} %magenta([%thread]) %highlight(%-5level) %yellow(%logger{36}) - %X{dd.trace_id} %X{dd.span_id} - %msg%n"
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %X{dd.trace_id} %X{dd.span_id} - %msg%n"
  file:
    name: ${logging.file.path}/demo-app.log
    path: logs
```

Note that at MyOrg we have configured the *Datadog Admission Controller* to allow automatic injection of APM trace libraries, which is the recommended configuration.

[^1]: https://docs.datadoghq.com/tracing/other_telemetry/connect_logs_and_traces/java

## Prerequisites

List of prerequisites prior to deploying the application with which we are going to test Datadog APM:

1. Create the ```datadog-demo``` namespace, previously added by us to the manifests of this PoC.
2. Open firewall ports so that *openshift on-prem* is able to download datadog tracing libraries (available at dtdg.com which points to a public github repo).
3. Enable automatic trace injection in the *Datadog Cluster Agent* *Admission Controller*.

## PoC with manually injected libraries configuration (not recommended)

Application manifest to be instrumented available at [k8s/depl-with-lib-conf.yaml](k8s/depl-with-lib-conf.yaml), where it has been necessary to update the *java tracer* download method with:

```curl -Lo /work-dir/dd-java-agent.jar https://dtdg.co/latest-java-tracer```

Note: it has been necessary to unblock this access route in the firewall so that our openshift on-prem is able to download this artifact from the internet (available on github).

Deploying the application:

```oc apply -f k8s/depl-with-lib-conf.yaml```

Deleting the application:

```oc delete -f k8s/depl-with-lib-conf.yaml```

## PoC with automatic library injection (recommended)

Application manifest to be instrumented available at [k8s/depl-with-lib-inj.yaml](k8s/depl-with-lib-inj.yaml)

Deploying the application:

```oc apply -f k8s/depl-with-lib-inj.yaml```

Deleting the application:

```oc delete -f k8s/depl-with-lib-inj.yaml```

## Testing the application with curl

As indicated [in this reference](https://github.com/DataDog/springblog?tab=readme-ov-file#testing-the-application), we launch a ```curl``` towards the OpenShift endpoint where we expose our frontend with an ```openshift route```:

```bash
for i in {1..100}; do
  echo "$i"
  curl http://springfront-datadog-demo.apps.cluster.example.com/upstream
done
```

## Screenshots

![demo-app-apm-poc](../images/demo-app-apm-poc.png)

![demo-app-profiles-poc](../images/demo-app-profiles-poc.png)

## References

- https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-admission-controller/
