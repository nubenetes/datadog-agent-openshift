# Datadog Agent Installation and Configuration Procedure on OpenShift

> [!IMPORTANT]
> **English Version**:
> This is a full translation of the original Spanish documentation (`README-Spanish.md`), which was manually written without AI.
>
> **Spanish Version / Versión en Español**:
> [README-Spanish.md](README-Spanish.md)

---

## 🤖 AI-Generated Summaries (NotebookLM)
Get a quick overview of this repository through AI-generated content:
- 📽️ [**Video Summary (English)**](resources/ai-summaries/Datadog_on_OpenShift_English.mp4): A high-level technical overview of the project.
- 📽️ [**Video Resumen (Spanish)**](resources/ai-summaries/Datadog_Operator_Spanish.mp4): Technical summary about using the Datadog Operator on OpenShift.
- 📊 [**Technical Presentation (PDF)**](resources/ai-summaries/Datadog_OpenShift_Technical_Blueprint.pdf): Detailed blueprint and architectural overview.
- 📊 [**Technical Presentation (PPTX)**](resources/ai-summaries/Datadog_OpenShift_Technical_Blueprint.pptx): Editable PowerPoint version of the technical blueprint.

---

1. [Introduction](#introduction)
2. [Requirements](#requirements)
3. [Debugging VS Tracing VS Profiling](#debugging-vs-tracing-vs-profiling)
4. [Features and Cost Control](#features-and-cost-control)
5. [Adding Kubernetes APM traces with Datadog Admission Controller](#adding-kubernetes-apm-traces-with-datadog-admission-controller)
   1. [Enable Datadog Admission Controller to mutate your PODs without using POD labels](#enable-datadog-admission-controller-to-mutate-your-pods-without-using-pod-labels)
   2. [Labels and Annotations on the POD we want to instrument without automatic injection of Datadog APM libraries (not recommended)](#labels-and-annotations-on-the-pod-we-want-to-instrument-without-automatic-injection-of-datadog-apm-libraries-not-recommended)
   3. [Labels and Annotations on the POD we want to instrument with automatic injection of Datadog APM libraries. Unified Service Tagging for easier label governance](#labels-and-annotations-on-the-pod-we-want-to-instrument-with-automatic-injection-of-datadog-apm-libraries-unified-service-tagging-for-easier-label-governance)
   4. [Enable the Profiler](#enable-the-profiler)
   5. [Autodiscovery with JMX](#autodiscovery-with-jmx)
      1. [Autodiscovery annotations (recommended)](#autodiscovery-annotations-recommended)
   6. [Logging configuration. features.logCollection.containerCollectAll VS Autodiscovery](#logging-configuration-featureslogcollectioncontainercollectall-vs-autodiscovery)
   7. [Datadog APM PoC with demo](#datadog-apm-poc-with-demo)
6. [Improving Kubernetes metrics with kube-state-metrics](#improving-kubernetes-metrics-with-kube-state-metrics)
7. [Datadog Tags with Autodiscovery and Unified Service Tagging](#datadog-tags-with-autodiscovery-and-unified-service-tagging)
   1. [Kubernetes Tags Extraction](#kubernetes-tags-extraction)
      1. [Kubernetes Host Tags](#kubernetes-host-tags)
   2. [Environment Variables defined in Example Company's Datadog Agent](#environment-variables-defined-in-example-companys-datadog-agent)
   3. [FinOps. Datadog Cost Control by tags](#finops-datadog-cost-control-by-tags)
8. [QoS in Datadog Agent](#qos-in-datadog-agent)
9. [Datadog Service Catalog](#datadog-service-catalog)
10. [Kubernetes Capacity Planning Dashboard](#kubernetes-capacity-planning-dashboard)
11. [Datadog API Tools](#datadog-api-tools)
    1. [Dogshell CLI (not recommended)](#dogshell-cli-not-recommended)
    2. [curl CLI (not recommended)](#curl-cli-not-recommended)
    3. [Datadog Postman API Collection](#datadog-postman-api-collection)
12. [Instrumentation (Traces, Metrics and Logs)](#instrumentation-traces-metrics-and-logs)
    1. [Single Step APM Instrumentation (Beta)](#single-step-apm-instrumentation-beta)
    2. [Dynamic instrumentation](#dynamic-instrumentation)
    3. [Java Tracing Library Configuration](#java-tracing-library-configuration)
13. [Log Management](#log-management)
    1. [Log Configuration Pipelines](#log-configuration-pipelines)
    2. [Logs and Traces Correlation](#logs-and-traces-correlation)
       1. [Automatic injection. Automatically Inject trace IDs and Span IDs into your logs](#automatic-injection-automatically-inject-trace-ids-and-span-ids-into-your-logs-1)
       2. [Java Log Collection](#java-log-collection)
    3. [Observability Pipelines](#observability-pipelines)
14. [Profiling in Java](#profiling-in-java)
15. [Remote Configuration](#remote-configuration)
16. [Advanced Prometheus autodiscovery configuration with Datadog agent (prometheusScrape)](#advanced-prometheus-autodiscovery-configuration-with-datadog-agent-prometheusscrape)
17. [Kubernetes Control Plane Monitoring](#kubernetes-control-plane-monitoring)
    1. [API Server](#api-server)
    2. [Etcd](#etcd)
    3. [Controller Manager](#controller-manager)
    4. [Scheduler](#scheduler)
18. [Kubernetes Audit Logs. Activate log collection in kubernetes](#kubernetes-audit-logs-activate-log-collection-in-kubernetes)
19. [Datadog Wizard to configure the application container for APM with YAML](#datadog-wizard-to-configure-the-application-container-for-apm-with-yaml)
20. [References](#references)
    1. [Kubernetes Security Context](#kubernetes-security-context)
    2. [Datadog Agent Helm Chart Installation](#datadog-agent-helm-chart-installation)
    3. [Datadog Billing](#datadog-billing)
    4. [Datadog Operator References](#datadog-operator-references)
       1. [Datadog Operator Installation via OpenShift Marketplace](#datadog-operator-installation-via-openshift-marketplace)
       2. [Datadog Operator Helm Chart Installation](#datadog-operator-helm-chart-installation-1)
    5. [Kubernetes APM with Datadog References](#kubernetes-apm-with-datadog-references)
    6. [Profiling vs Tracing](#profiling-vs-tracing-1)

## Introduction

There are [several procedures](https://docs.datadoghq.com/containers/kubernetes/installation) for installing Datadog Agent on OpenShift[^7]:
1. [ ] [Solution 1](solution-1-helm-chart/README.md). We use the **Datadog Agent** Helm Chart: 
   1. Helm Chart to deploy *Datadog Agent* on OpenShift 4.x: https://github.com/DataDog/helm-charts/tree/main/charts/datadog
   2. Deploy the Datadog Agent with a simple *[values.yaml](solution-1-helm-chart/values.yaml)* associated with its Helm Chart.
   3. It will be necessary to apply the [scc.yaml](solution-1-helm-chart/scc.yaml) manifest of class ```SecurityContextConstraints``` to enable the full set of Datadog Agent features: ```oc apply -f scc.yaml```
2. [x] [Solution 2](solution-2-operator/README.md). In principle, this would be the most recommended procedure due to the benefits provided by Kubernetes Operators, although in this case we find less documentation. We use **Datadog Operator** (a [*Kubernetes Operator*](https://www.redhat.com/en/topics/containers/what-is-a-kubernetes-operator)):
   1. Three options available to deploy **Datadog Operator**:
        1. [ ] Option A: Manual 1-click installation in OpenShift Marketplace: [*Deploy the Datadog Operator in an OpenShift cluster*](https://github.com/DataDog/datadog-operator/blob/main/docs/install-openshift.md)
        2. [ ] Option B: [Helm Chart](https://github.com/DataDog/helm-charts/blob/main/charts/datadog-operator) to deploy *Datadog Operator* on OpenShift 4.x: Configuration attempt available in [solution-2-operator/datadog-operator-helm-chart/values.yaml](solution-2-operator/datadog-operator-helm-chart/values.yaml)
        3. [x] **Option C:** Manifest [operatorhubio-catalog.yaml](solution-2-operator/datadog-operator-olm/operatorhubio-catalog.yaml) and [datadog-olm.yaml](solution-2-operator/datadog-operator-olm/datadog-olm.yaml) from [Operator Lifecycle Manager (OLM)](https://operatorhub.io/operator/datadog-operator) with which to subscribe to the datadog operator:
           1. ```oc create secret -n openshift-operators generic datadog-secret --from-literal api-key=<> --from-literal app-key=<>```
           2. ```oc apply -f operatorhubio-catalog.yaml```
           3. ```oc apply -f datadog-olm.yaml```
   2. After launching the operator, we can proceed with **Datadog Agent** through a YAML manifest that includes the CRD defined by the operator. We deploy the *DatadogAgent* manifest [datadog-agent-on-openshift.yaml](solution-2-operator/datadog-agent-on-openshift.yaml) adapted to MyOrg's needs:
        1. [x] ```oc apply -f datadog-agent-on-openshift.yaml```
        2. [x] We apply the [scc.yaml](solution-2-operator/scc.yaml) manifest of class ```SecurityContextConstraints``` to enable the full set of Datadog Agent features: ```oc apply -f scc.yaml```
        3. Uninstallation: ```oc delete -f datadog-agent-on-openshift.yaml; oc delete -f scc.yaml```
3. [ ] Solution 3 (discarded). Manual installation and configuration of the Datadog Agent with DaemonSet.

[^7]: https://www.datadoghq.com/blog/openshift-monitoring-with-datadog/

**The installation method implemented at MyOrg corresponds to "Solution 2" with "Option C".**

**Datadog is deployed in OCP Prod since May 05, 2026. Its deployment in OCP NoProd is discarded.**

## Requirements

- Datadog Cloud user account with:
  - [x] API-Key (required)
  - [ ] app-key (optional)
- Creation of namespace/project in OpenShift:
  - [ ] In the case of [Solution 1](solution-1-helm-chart/README.md): Dedicated namespace in kubernetes for datadog, e.g., **datadog**.
  - [x] In [Solution 2](solution-2-operator/README.md) we use the existing **openshift-operators** namespace.
- Creation of a *secret* in our namespace so that OpenShift can log in to *DockerHub*, necessary to download the APM libraries[^1] that must be automatically injected[^2], as indicated in the [reference](https://docs.openshift.com/container-platform/4.13/openshift_images/image-streams-manage.html):
  - [x] ```oc create secret docker-registry dockerhub-secret -n <> --docker-server=https://registry.hub.docker.com/v2 --docker-username=<> --docker-password=<> --docker-email=<>@example.com```
  - [x] ```oc secrets link default dockerhub-secret --for=pull -n <>```

[^1]: https://docs.datadoghq.com/tracing/trace_collection/library_injection_local/?tab=kubernetes

[^2]: https://www.docker.com/increase-rate-limit

## Debugging VS Tracing VS Profiling

- **Debugging** is the process of looking for bugs and their cause in applications. A bug can be an error or just some unexpected behavior (e.g., a user complains that he/she receives an error when he/she uses an invalid date format). Typically a debugger is used that can pause the execution of an application, examine variables and manipulate them.
- **Tracing** *"trace is a log of events within to the program"*(Whitham)[^27]. those events can be ordered chronologically. that's why they often contain a timestamp. Tracing is the process of generating and collecting those events. the use case is typically flow analysis.
- **Profiling** is a dynamic analysis process that collects information about the execution of an application. the type of information that is collected depends on your use case, e.g., the number of requests. the result of profiling is a profile with the collected information. the source for a profile can be exact events (see tracing below) or a sample of events that occurred. because the data is aggregated in a profile it is irrelevant when and in which order the events happened.

Trace:

```bash
[2026-05-05T11:22:09.815479Z] [INFO] [Thread-1] Request started
[2026-05-05T11:22:09.935612Z] [INFO] [Thread-1] Request finished
[2026-05-05T11:22:59.344566Z] [INFO] [Thread-1] Request started
[2026-05-05T11:22:59.425697Z] [INFO] [Thread-1] Request finished
```

Profile:

```bash
2 "Request finished" Events
2 "Request started" Events
```

So if tracing and profiling measure the same events you can construct a profile from a trace but not the other way around.

[^27]: https://www.jwhitham.org/2016/02/profiling-versus-tracing.html

## Features and Cost Control

Many of the features that we can enable in our Datadog Agent involve subscribing to a specific Datadog product. For example, *Live Processes* monitoring requires a subscription to *Infrastructure -> Enterprise plan*.

https://www.datadoghq.com/pricing/allotments/

## Adding Kubernetes APM traces with Datadog Admission Controller

[*Datadog Admission Controller*](https://docs.datadoghq.com/containers/cluster_agent/admission_controller/?tab=helm) is a component of the *Datadog Cluster Agent* that simplifies the configuration of an application POD.

We use *Datadog Admission Controller* to inject environment variables and mount the necessary volumes in new application PODs, automatically configuring trace communication between the POD and the Agent. This controller is responsible for **automatically injecting** *APM traceability* libraries, such as the [*Java Tracer*](https://docs.datadoghq.com/tracing/trace_collection/automatic_instrumentation/dd_libraries/java) for java.

Datadog APM [is enabled by default](https://github.com/DataDog/helm-charts/blob/e5284d563b635628aa5650b827e16a2e15063b4e/charts/datadog/values.yaml) over *Unix Domain Socket (UDS)*. It is necessary to change the communication with the Datadog Agent from *"socket"* to *"hostip"*. According to the following [reference](https://docs.datadoghq.com/containers/troubleshooting/admission-controller/?tab=helm#application-pods-are-not-created):

> Admission Controller’s injection mode (socket, hostip, service) is set by the configuration of your Cluster Agent. For example, if you have socket mode enabled in your Agent, Admission Controller also uses socket mode.
> **If you are using GKE Autopilot or OpenShift, you need to use a specific injection mode.**

According to this other [OpenShift documentation](https://docs.datadoghq.com/integrations/openshift/?tab=helm#restricted-scc-operations):

> If the Operator has been deployed with Operator Lifecycle Manager (OLM), then the necessary default SCCs present in OpenShift are automatically associated with the datadog-agent-scc ServiceAccount. The Agent can then be deployed with the DatadogAgent CustomResourceDefinition, referencing this Service Account on the Node Agent and Cluster Agent pods.

> The recommended ingestion method for Dogstatsd, APM, and logs is to bind the Datadog Agent to a host port. This way, the target IP is constant and easily discoverable by your applications. The default restricted OpenShift SCC does not allow binding to the host port. You can set the Agent to listen on it’s own IP, but you need to handle the discovery of that IP from your application.

Therefore, we apply specific SCC permissions for the Datadog *Service Account* (datadog-agent-scc), located in the [scc.yaml](solution-2-operator/scc.yaml) file.

It should also be noted that by default, PODs launched in OpenShift are identified with the OpenShift *"default"* Service Account (SA), which is linked to the "restricted-v2" SCC. For this reason, it is more effective to establish the connection via "hostip" to avoid creating a specific SCC for all PODs that we want to monitor with Datadog (note: it is not convenient to modify the default SCCs).

### Enable Datadog Admission Controller to mutate your PODs without using POD labels

By default, *Datadog Admission Controller* only mutates pods labeled with a specific label. To [enable mutation for your pods](https://docs.datadoghq.com/tracing/trace_collection/library_injection_local/?tab=kubernetes#step-1---enable-datadog-admission-controller-to-mutate-your-pods), the label ```admission.datadoghq.com/enabled: "true"``` is added to your pod's specification (spec):

```yaml
labels:
  admission.datadoghq.com/enabled: true
```

**At MyOrg, it is not necessary to use this POD label**. Instead, we enable automatic APM trace injection in the *Datadog Admission Controller* by configuring the *Datadog Cluster Agent*[^8] with ```clusterAgent.admissionController.mutateUnlabelled: "true"``` (or ```DD_ADMISSION_CONTROLLER_MUTATE_UNLABELLED=true```).

[^8]: A component of the *Datadog Agent*

### Labels and Annotations on the POD we want to instrument without automatic injection of Datadog APM libraries (not recommended)

In those use cases where APM libraries cannot be automatically injected by [*Datadog Admission Controller*](https://docs.datadoghq.com/containers/cluster_agent/admission_controller/), it will be necessary to activate APM monitoring for our PODs through [the following configuration](https://www.datadoghq.com/blog/auto-instrument-kubernetes-tracing-with-datadog/):

```yaml
labels:
  admission.datadoghq.com/enabled: true
  admission.datadoghq.com/config.mode: "hostip"
annotations:
  admission.datadoghq.com/java-lib.version: "latest"
```

### Labels and Annotations on the POD we want to instrument with automatic injection of Datadog APM libraries. Unified Service Tagging for easier label governance

Once we have activated automatic APM library injection in [*Datadog Admission Controller*](https://docs.datadoghq.com/containers/cluster_agent/admission_controller/), we can instrument our applications as follows[^4], including [*Unified Service Tagging*](https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: mynamespace
  labels: 
    tags.datadoghq.com/env: "dev" # Configuring unified service tagging (environment variable for resource governance)
    tags.datadoghq.com/service: "<myServiceID>" # Configuring unified service tagging (label for resource governance)
    tags.datadoghq.com/version: "1" # Configuring unified service tagging (label for resource governance)
spec:
  # (...)
  selector:
    matchLabels:
      name: myapp
  # (...)      
  template:
    metadata:
      labels: 
        name: myapp
        tags.datadoghq.com/env: "dev" # Configuring unified service tagging
        tags.datadoghq.com/service: "<myServiceID>" # Configuring unified service tagging
        tags.datadoghq.com/version: "1" # Configuring unified service tagging
      annotations:
        admission.datadoghq.com/java-lib.version: "latest"
# (...)
---
apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: mynamespace
spec:
  # (...)
  selector:
    name: myapp
```

[^4]: https://www.datadoghq.com/blog/auto-instrument-kubernetes-tracing-with-datadog/

### Enable the Profiler

We enable the *java profiler*[^5] by adding the *DD_PROFILING_ENABLED* environment variable to our java container[^6]:

```yaml
# (...)
apiVersion: apps/v1
kind: Deployment
metadata:
   # (...)
spec:
   # (...)
  template:
    metadata:
      labels:
         # (...)
      annotations:
         # (...)
    spec:
      containers:
      - image: # (...)
         # (...)
         env:
         - name: DD_PROFILING_ENABLED # https://docs.datadoghq.com/profiler/enabling/java/?tab=datadogprofiler
           value: 'true'
         ports:
         - containerPort: # (...)
# (...)
```

[^5]: https://docs.datadoghq.com/profiler/enabling/

[^6]: https://docs.datadoghq.com/getting_started/profiler/

### Autodiscovery with JMX

In containerized environments, there are few differences in how the Agent connects to the JMX server. *Autodiscovery* features make dynamic configuration of these integrations possible. We will use Datadog's JMX-based integrations to collect JMX application metrics from pods in Kubernetes.

If we enable the *java tracer* in our applications, we can alternatively use the *java runtime* metrics feature to send these metrics to the Agent.

```yaml
apiVersion: datadoghq.com/v2alpha1
kind: DatadogAgent
metadata:
  name: datadog
spec:
  #(...)
  override:
    nodeAgent:
      image:
        jmxEnabled: true
```

#### Autodiscovery annotations (recommended)

In this method[^13], the ```JMX check``` configuration is applied using annotations on java-based PODs. This allows the Agent to automatically configure the ```JMX check``` when a container starts. These annotations must be on the created Pod, and not on the object that creates the Pod (Deployment, DaemonSet, etc.).

We use the following template for *Autodiscovery* annotations:

Note: Replace *<INTEGRATION_NAME>* with one of the [available JMX integrations](https://docs.datadoghq.com/containers/guide/autodiscovery-with-jmx/?tab=operator#available-jmx-integrations).
Note 2: Through these annotations we can integrate *JMX Custom Metrics* into *Datadog Metrics*, being necessary to specify in the manifest below each of the metrics to be added. In this case there does not seem to be a generic configuration that allows automatic *discovery* of all those *JMX Custom Metrics*. Another interesting option would be the *Prometheus Custom Metrics* detailed in the chapter on [Advanced Prometheus autodiscovery configuration with Datadog agent (prometheusScrape)](#advanced-prometheus-autodiscovery-configuration-with-datadog-agent-prometheusscrape), which does allow greater automation without it being necessary to add each of the *custom metrics* in our manifests.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: <POD_NAME>
  annotations:
    ad.datadoghq.com/<CONTAINER_IDENTIFIER>.checks: |
      {
        "<INTEGRATION_NAME>": {
          "init_config": {
            "is_jmx": true,
            "collect_default_metrics": true
          },
          "instances": [{
            "host": "%%host%%",
            "port": "<JMX_PORT>"
          }]
        }
      }      
    # (...)
spec:
  containers:
    - name: '<CONTAINER_IDENTIFIER>'
      # (...)
      env:
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: JAVA_OPTS
          value: >-
            -Dcom.sun.management.jmxremote
            -Dcom.sun.management.jmxremote.authenticate=false
            -Dcom.sun.management.jmxremote.ssl=false
            -Dcom.sun.management.jmxremote.local.only=false
            -Dcom.sun.management.jmxremote.port=<JMX_PORT>
            -Dcom.sun.management.jmxremote.rmi.port=<JMX_PORT>
            -Djava.rmi.server.hostname=$(POD_IP)            
```

[^13]: https://docs.datadoghq.com/containers/guide/autodiscovery-with-jmx/?tab=operator

### Logging configuration. features.logCollection.containerCollectAll VS Autodiscovery

[This reference](https://app.datadoghq.eu/logs/onboarding/container) is useful for getting started with container log ingestion.

See the [sample manifest with logs and metrics collection enabled](https://github.com/DataDog/datadog-operator/blob/main/examples/datadogagent/v2alpha1/datadog-agent-with-logs-apm.yaml) for a complete example. You can set ```features.logCollection.containerCollectAll``` to ```true``` to collect logs from all discovered containers by default. When set to ```false``` (default), you need to specify Autodiscovery log configurations to enable log collection.

Autodiscovery enables you to use templates to configure log collection (and other capabilities) on containers.

We can configure logging processing rules with the following method[^12] [^20]:

```yaml
apiVersion: v1
kind: Pod
# (...)
metadata:
  name: '<POD_NAME>'
  annotations:
    ad.datadoghq.com/<CONTAINER_IDENTIFIER>.logs: '[<LOG_CONFIG>]'
    # (...)
spec:
  containers:
    - name: '<CONTAINER_IDENTIFIER>'
# (...)
```

Example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: mynamespace
  labels: 
    tags.datadoghq.com/env: "dev" # Configuring unified service tagging
    tags.datadoghq.com/service: "<myServiceID>" # Configuring unified service tagging
    tags.datadoghq.com/version: "1" # Configuring unified service tagging
spec:
   # (...)
   template:
    metadata:
      labels: 
        name: myapp
        tags.datadoghq.com/env: "dev" # Configuring unified service tagging
        tags.datadoghq.com/service: "<myServiceID>" # Configuring unified service tagging
        tags.datadoghq.com/version: "1" # Configuring unified service tagging
      annotations:
        admission.datadoghq.com/java-lib.version: "latest"
        ad.datadoghq.com/myapp.logs: '[{"source": "java", "service": "<myServiceID>", "log_processing_rules": [{"type": "multi_line", "name": "log_start_with_date", "pattern" : "\\d{4}-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])"}]}]'
# (...)
```

[^12]: https://docs.datadoghq.com/containers/kubernetes/log/?tab=datadogoperator#configuration
[^20]: https://docs.datadoghq.com/agent/logs/advanced_log_collection/?tab=kubernetes#filter-logs

### Datadog APM PoC with demo

Correct configuration of Datadog APM has been validated with the following public demo as a *happy path*: [apm-poc/README.md](apm-poc/README.md).

## Improving Kubernetes metrics with kube-state-metrics

By default, the *Datadog Agent* collects and displays a reduced set of system metrics, such as CPU, network, disk, and memory usage. With a simple configuration in the [datadog-agent-on-openshift.yaml](solution-2-operator/datadog-agent-on-openshift.yaml) manifest of our *Datadog Operator*[^11], we manage to expand the set of data collected from Kubernetes. This configuration consists of adding *kube-state-metrics*[^9] to the cluster, a component that provides more detailed metrics on the state of the cluster.

*kube-state-metrics*[^10] listens to the *Kubernetes API* and generates metrics on the state of Kubernetes logical objects: node state, node capacity (CPU and memory), number of *desired/available/unavailable/updated* replicas per deployment, pod state (e.g., *waiting*, *running*, *ready*), etc. In [this link](https://docs.datadoghq.com/containers/kubernetes/data_collected/#kube-state-metrics) we can find a complete list of the number of metrics that Datadog collects from *kube-state-metrics*.

```yaml
spec:
  features:
      kubeStateMetricsCore:
        enabled: true
      clusterChecks:
        enabled: true
        useClusterChecksRunners: true
```

[^9]: https://www.datadoghq.com/blog/monitor-kubernetes-docker/
[^10]: https://github.com/kubernetes/kube-state-metrics
[^11]: https://github.com/DataDog/datadog-operator/blob/main/docs/kubernetes_state_metrics.md

## Datadog Tags with Autodiscovery and Unified Service Tagging

Datadog recommends assigning *Tags* [with *Autodiscovery*](https://docs.datadoghq.com/getting_started/tagging/assigning_tags/?tab=containerizedenvironments), a method that allows [*Unified Service Tagging*](https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging), a single configuration point that covers all Datadog telemetry.

Reference of interest: [Best practices for tagging your infrastructure and applications](https://www.datadoghq.com/blog/tagging-best-practices/)

### Kubernetes Tags Extraction 

The [Datadog Agent](solution-2-operator/datadog-agent-on-openshift.yaml)[^16] can create and assign *tags* from all metrics, traces, and logs emitted by a Pod, based on its labels or annotations.

*Datadog Agent* autodiscovers and attaches *tags* emitted by pods or containers. The list of automatically extracted *tags* depends on the agent's [cardinality configuration](https://docs.datadoghq.com/getting_started/tagging/assigning_tags/?tab=containerizedenvironments#environment-variables):

| TAG                         | CARDINALITY  | SOURCE                                                                | REQUIREMENT                                           |
| :-------------------------- | :----------- | :-------------------------------------------------------------------- | :---------------------------------------------------- |
| container_id                | High         | Pod   status                                                          | N/A                                                   |
| display_container_name      | High         | Pod   status                                                          | N/A                                                   |
| pod_name                    | Orchestrator | Pod   metadata                                                        | N/A                                                   |
| oshift_deployment           | Orchestrator | Pod annotation openshift.io/deployment.name                           | OpenShift environment and pod annotation must exist   |
| kube_ownerref_name          | Orchestrator | Pod   ownerref                                                        | Pod   must have an owner                              |
| kube_job                    | Orchestrator | Pod   ownerref                                                        | Pod   must be attached to a cronjob                   |
| kube_job                    | Low          | Pod   ownerref                                                        | Pod   must be attached to a job                       |
| kube_replica_set            | Low          | Pod   ownerref                                                        | Pod   must be attached to a replica set               |
| kube_service                | Low          | Kubernetes   service discovery                                        | Pod   is behind a Kubernetes service                  |
| kube_daemon_set             | Low          | Pod   ownerref                                                        | Pod   must be attached to a DaemonSet                 |
| kube_container_name         | Low          | Pod   status                                                          | N/A                                                   |
| kube_namespace              | Low          | Pod   metadata                                                        | N/A                                                   |
| kube_app_name               | Low          | Pod label app.kubernetes.io/name                                      | Pod   label must exist                                |
| kube_app_instance           | Low          | Pod label app.kubernetes.io/instance                                  | Pod   label must exist                                |
| kube_app_version            | Low          | Pod label app.kubernetes.io/version                                   | Pod   label must exist                                |
| kube_app_component          | Low          | Pod label app.kubernetes.io/component                                 | Pod   label must exist                                |
| kube_app_part_of            | Low          | Pod label app.kubernetes.io/part-of                                   | Pod   label must exist                                |
| kube_app_managed_by         | Low          | Pod label app.kubernetes.io/managed-by                                | Pod   label must exist                                |
| env                         | Low          | Pod label tags.datadoghq.com/env or   container envvar DD_ENV         | *Unified service tagging enabled*                     |
| version                     | Low          | Pod label tags.datadoghq.com/version or   container envvar DD_VERSION | *Unified service tagging enabled*                     |
| service                     | Low          | Pod label tags.datadoghq.com/service or   container envvar DD_SERVICE | *Unified service tagging enabled*                     |
| pod_phase                   | Low          | Pod   status                                                          | N/A                                                   |
| oshift_deployment_config    | Low          | Pod annotation openshift.io/deployment-config.name                    | OpenShift   environment and pod annotation must exist |
| kube_ownerref_kind          | Low          | Pod   ownerref                                                        | Pod   must have an owner                              |
| kube_deployment             | Low          | Pod   ownerref                                                        | Pod   must be attached to a deployment                |
| kube_replication_controller | Low          | Pod   ownerref                                                        | Pod   must be attached to a replication controller    |
| kube_stateful_set           | Low          | Pod   ownerref                                                        | Pod   must be attached to a statefulset               |
| persistentvolumeclaim       | Low          | Pod   spec                                                            | A   PVC must be attached to the pod                   |
| kube_cronjob                | Low          | Pod   ownerref                                                        | Pod   must be attached to a cronjob                   |
| image_name                  | Low          | Pod   spec                                                            | N/A                                                   |
| short_image                 | Low          | Pod   spec                                                            | N/A                                                   |
| image_tag                   | Low          | Pod   spec                                                            | N/A                                                   |
| eks_fargate_node            | Low          | Pod   spec                                                            | EKS   Fargate environment                             |

[^16]:(https://docs.datadoghq.com/containers/kubernetes/tag/?tab=datadogoperator)

#### Kubernetes Host Tags

The [Agent](solution-2-operator/datadog-agent-on-openshift.yaml) can attach Kubernetes environment information as *“host tags”*:

| TAG               | CARDINALITY | SOURCE                                                 | REQUIREMENT                                                    |
| ----------------- | ----------- | ------------------------------------------------------ | -------------------------------------------------------------- |
| kube_cluster_name | Low         | DD_CLUSTER_NAME envvar or   cloud provider integration | DD_CLUSTER_NAME envvar or   cloud provider integration enabled |
| kube_node_role    | Low         | Node label node-role.kubernetes.io/<role>              | Node   label must exist                                        |

### Environment Variables defined in Example Company's Datadog Agent

The following variables have been defined in the ```nodeAgent``` configuration of our [Datadog Agent](solution-2-operator/datadog-agent-on-openshift.yaml):

- ```DD_ENV```[^14]: Sets the global env tag for all data emitted.
- ```DD_CONTAINER_EXCLUDE```: Blocklist of containers to exclude (separated by spaces).
- ```DD_CONTAINER_INCLUDE```: Allowlist of containers to include (separated by spaces).
- etc.

We can add *custom tags*[^15] in the same manifest, with the ```DD_TAGS``` environment variable followed by ```key:value``` pairs, separated by spaces:

```yaml
- name: DD_TAGS 
  value: platform:k8s cluster-name:ocp-devtest team:arquitectura
```

[^14]: https://docs.datadoghq.com/containers/docker/?tab=standard#environment-variables
[^15]: https://www.datadoghq.com/blog/monitoring-kubernetes-with-datadog/

### FinOps. Datadog Cost Control by tags

[This Dashboard](https://app.datadoghq.eu/dashboard/fbf-a5e-zfk/vma-apm-hosts) has been created by Datadog to identify hosts with APM and USM activated. They have enabled *Usage Attribution* to track costs by tags in app.datadoghq.eu -> Plan & Usage.

## QoS in Datadog Agent

Datadog support recommendation[^3]:

> Thanks again for reaching out to the Datadog support team! My name is Timothée and I’ll handle your request from now on.
> 
> Unfortunately, the Agent resource usage as any observability solution is highly dependent on the number of features enabled, the number of workloads it needs to monitor and so on : there is no baseline we can provide as for instance, in our own clusters, our Agent uses multiple cores and Gb of memory while on kind, 128m and 256Mi would be enough.
>
> Thus, we recommend watching the container.cpu.usage and container.memory.usage metrics of the Agent containers over a week to then use this as a baseline request and use usually 2 times the requests as limit to handle burst. Unfortunately, you are excluding the Agent metrics with DD_CONTAINER_EXCLUDE so you won't be able to use Datadog metrics for that purpose, but you could use oc top during 2-3 days to review the Agent values and adjust accordingly. It seems you might have taken the containers.system-probe resources limits from https://github.com/DataDog/datadog-operator/blob/main/docs/configuration.v2alpha1.md, so the system-probe might not really need that many resources in your environment.
>
> Let me know if you have any questions on the above!

[^3]: https://help.datadoghq.com/hc/en-us/requests/ticket-id

## Datadog Service Catalog

[*Datadog Service Catalog*](https://docs.datadoghq.com/service_catalog/) provides a consolidated view of monitored services, combining ownership metadata, performance analysis, security analysis, cost control, and more.

## Kubernetes Capacity Planning Dashboard

The [*Kubernetes Capacity Planning* Dashboard](https://app.datadoghq.eu/dashboard/dashboard-id/kubernetes-capacity-planning) available at [github.com/DataDog/effective-dashboards](https://github.com/DataDog/effective-dashboards/) has been imported.

Procedure: 

1. Datadog UI -> Dashboards -> New Dashboard (named *Kubernetes Capacity Planning*)
2. Datadog UI -> Dashboards -> List -> All Custom -> click on *Kubernetes Capacity Planning* -> Configure -> Import dashboard JSON... -> select json file downloaded locally from [github.com/DataDog/effective-dashboards -> KubernetesCapacityPlanning.json](https://github.com/DataDog/effective-dashboards/blob/main/dashboards/kubernetes_capacity_planning/KubernetesCapacityPlanning.json)

Current link of [Kubernetes Capacity Planning Dashboard](https://app.datadoghq.eu/dashboard/dashboard-id/kubernetes-capacity-planning)

## Datadog API Tools

Listed below are several tools with which to interact with the [Datadog API](https://docs.datadoghq.com/api/latest/).

### Dogshell CLI (not recommended)

We can use [Dogshell](https://docs.datadoghq.com/developers/guide/dogshell-quickly-use-datadog-s-api-from-terminal-shell/) to interact with the Datadog API via CLI, although it is currently a poorly documented tool.

  ```bash
  $ pip install datadog
  $ dog metric post test_metric 1
  What is your api key? (Get it here: https://app.datadoghq.com/account/settings#api)
  What is your app key? (Get it here: https://app.datadoghq.com/account/settings#api)
  Wrote /home/<username>/.dogrc
  
  $ vim $HOME/.dogrc
  $ cat $HOME/.dogrc
  [Connection]
  apikey = <>
  appkey = <>
  api_host = datadoghq.eu

  $ dog -h
  ```

### curl CLI (not recommended)

Example:

```bash
curl -X GET "https://api.datadoghq.eu/api/v2/container_images" \
-H "Accept: application/json" \
-H "DD-API-KEY: ${DD_API_KEY}" \
-H "DD-APPLICATION-KEY: ${DD_APP_KEY}"
```

### Datadog Postman API Collection

A better-documented solution for interacting with the [Datadog API](https://docs.datadoghq.com/api/latest/) is the [Datadog Postman API Collection](https://www.postman.com/datadog/workspace/datadog-s-public-workspace/overview), whose collection can be imported with a *fork* into our local Postman[^16]:

![datadog_postman_01.png](images/datadog_postman_01.png)

[^16]: https://docs.datadoghq.com/getting_started/api/

## Instrumentation (Traces, Metrics and Logs)

Instrumentation[^24] is the process of adding code to your application to capture and report observability data to Datadog, such as traces, metrics, and logs. Datadog provides instrumentation libraries for various programming languages and frameworks.

You can automatically instrument your application when you install the Datadog Agent with [Single Step Instrumentation](https://docs.datadoghq.com/tracing/trace_collection/automatic_instrumentation/single-step-apm/?tab=kubernetes) or when you manually add Datadog tracing libraries to your code.

You can use custom instrumentation by embedding tracing code directly into your application code. This allows you to programmatically create, modify, or delete traces to send to Datadog.

[^24]: https://docs.datadoghq.com/tracing/glossary/#instrumentation

### Single Step APM Instrumentation (Beta)

If you install or update a Datadog Agent with the Enable APM Instrumentation (beta) option selected, the Agent is installed and configured to enable APM. **This allows you to automatically instrument your application, without any additional installation or configuration steps.** Restart services for this instrumentation to take effect.[^23]

> Single Step Instrumentation doesn't instrument applications in the namespace where you install the Datadog Agent. It's recommended to install the Agent in a separate namespace in your cluster where you don't run your applications.

[^23]: https://docs.datadoghq.com/tracing/trace_collection/automatic_instrumentation/single-step-apm/?tab=kubernetes

### Dynamic instrumentation

Instantly add missing log, metric or span to your production system[^25]. No redeploy required, Dynamic Instrumentation safely collects new observability data in real-time. Remove the instrumentation when it is no longer needed.

Remote Configuration allows you to remotely configure the behavior of Datadog components and receive configurations and security detection rules of Datadog products for your organization[^26].

[^25]: https://app.datadoghq.eu/dynamic-instrumentation/probes
[^26]: https://app.datadoghq.eu/organization-settings/remote-config

### Java Tracing Library Configuration

The supported features and configuration options for the tracing library are the same for library injection as for other installation methods, and can be set with environment variables. Read the Datadog library configuration page[^29] for your language for more details.

For example, you can turn on **Application Security Monitoring** or **Continuous Profiler**, each of which may have billing impact[^28]:

- For Kubernetes, set the ```DD_APPSEC_ENABLED``` or ```DD_PROFILING_ENABLED``` environment variables to true in the underlying application pod’s deployment file.
- For hosts and containers, set the ```DD_APPSEC_ENABLED``` or ```DD_PROFILING_ENABLED``` container environment variables to ```true```, or in the injection configuration, specify an ```additional_environment_variables``` section like the following YAML example:

```yaml
additional_environment_variables:
- key: DD_PROFILING_ENABLED
  value: true
- key: DD_APPSEC_ENABLED
  value: true
```

After you set up the tracing library with your code and configure the Agent to collect APM data, optionally configure the tracing library as desired, including setting up [Unified Service Tagging](https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/).

All configuration options below have system property and environment variable equivalents. If the same key type is set for both, the system property configuration takes priority. **System properties can be set as JVM flags**.[^30]

**At MyOrg we use the following java configuration variables (on hosts and in containers):**

| System property (JVM flag)                                                                                                                           | Environment variable                                                                                                                                 | Details                                                                                                                 |
| ---------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| ```dd.service.mapping="as400:db2<myServiceID>,postgresql:pg<myServiceID>"```<br>Example:<br>```dd.service.mapping="as400:db2tcl,postgresql:pgtcl"``` | DD_SERVICE_MAPPING="as400:db2\<myServiceID\>,postgresql:pg\<myServiceID\>"<br>Example:<br>"DD_SERVICE_MAPPING=as400:db2**tcl**,postgresql:pg**tcl**" | Dynamically rename services via configuration. Useful for making databases have distinct names across different services |
| ```dd.trace.db.client.split-by-instance=true```                                                                                                      | DD_TRACE_DB_CLIENT_SPLIT_BY_INSTANCE=true                                                                                                            | When set to true db spans get assigned the instance name as the service name                                             |

[^28]: https://docs.datadoghq.com/tracing/trace_collection/library_injection_local/?tab=kubernetes
[^29]: https://docs.datadoghq.com/tracing/trace_collection/library_config/
[^30]: https://docs.datadoghq.com/tracing/trace_collection/library_config/java/

## Log Management

Start with *Log Management in Datadog*[^17], [*Advanced Log Collection*](https://docs.datadoghq.com/agent/logs/advanced_log_collection/?tab=kubernetes), [*Log Configuration Pipelines*](https://docs.datadoghq.com/logs/log_configuration/pipelines/?tab=source#pipelines-goal) and [*Correlate request logs with traces automatically*](https://www.datadoghq.com/blog/request-log-correlation/).

[^17]: https://docs.datadoghq.com/logs/guide/best-practices-for-log-management/

### Log Configuration Pipelines

The available *Log Configuration Pipelines* can be found [here](https://app.datadoghq.eu/logs/pipelines), as explained in [*Log Configuration Pipelines*](https://docs.datadoghq.com/logs/log_configuration/pipelines/?tab=source#pipelines-goal).

### Logs and Traces Correlation

The correlation between Datadog APM and Datadog Log Management[^19] is improved by the injection of trace IDs, span IDs, env, service, and version as attributes in your logs. With these fields you can find the exact logs associated with a specific service and version, or all logs correlated to an observed trace.

It is recommended to configure your application’s tracer with ```DD_ENV```, ```DD_SERVICE```, and ```DD_VERSION```. This will provide the best experience for adding env, service, and version. See the unified service tagging documentation for more details.

Before you begin, ensure log collection is configured in your java app. See Java Log Collection for Log4j, Log4j 2, or Logback instructions. [^21]

Before correlating traces with logs, ensure your logs are either sent as JSON, or [parsed by the proper language level log processor](https://docs.datadoghq.com/agent/logs/). Your language level logs must be turned into Datadog attributes in order for traces and logs correlation to work.

**Starting in version 0.74.0, the Java tracer automatically injects trace correlation identifiers into JSON formatted logs.**

Note: If you are not using a Datadog Log Integration to parse your logs, custom log parsing rules need to ensure that ```dd.trace_id``` and ```dd.span_id``` are being parsed as strings. For more information, see [Correlated Logs Not Showing Up in the Trace ID Panel](https://docs.datadoghq.com/tracing/troubleshooting/correlated-logs-not-showing-up-in-the-trace-id-panel/?tab=custom).

If logs are in JSON format, Datadog automatically parses the log messages to extract log attributes. Use the Log Explorer to view and troubleshoot your logs.[^22]

#### Automatic injection. Automatically Inject trace IDs and Span IDs into your logs

If APM is enabled for this application, you can correlate logs and traces by enabling trace ID injection. See [Connecting Java Logs and Traces](https://docs.datadoghq.com/tracing/other_telemetry/connect_logs_and_traces/java/?tab=log4j2) for more information.

_Starting in version 0.74.0, the Java tracer automatically injects trace correlation identifiers into JSON formatted logs_. **For earlier versions**, enable automatic injection in the Java tracer by adding ```dd.logs.injection=true``` as a system property, or through the environment variable ```DD_LOGS_INJECTION=true```[^21]. Full configuration details can be found on the Java tracer configuration page.

Note: If the attribute.path for your trace ID is not ```dd.trace_id```, ensure that your trace ID reserved attribute settings account for the ```attribute.path```. For more information, see Correlated Logs Not Showing Up in the Trace ID Panel.

**Note: In MyOrg's case, it is not necessary to activate the ```DD_LOGS_INJECTION=true``` variable thanks to the automatic injection of the latest versions of Java tracer.**

#### Java Log Collection

To send your logs to Datadog, log to a file and tail that file with your Datadog Agent. To address this issue, configure your logging library to produce your logs in JSON format. By logging to JSON, you:

- Ensure that the stack trace is properly wrapped into the log event.
- Ensure that all log event attributes (such as severity, logger name, and thread name) are properly extracted.
- Gain access to Mapped Diagnostic Context (MDC) attributes, which you can attach to any log event.
- Avoid the need for custom parsing rules.

The following instructions[^22] show setup examples for the Log4j, Log4j 2, and Logback logging libraries:

For Log4j, log in JSON format by using the SLF4J module log4j-over-slf4j combined with Logback. log4j-over-slf4j cleanly replaces Log4j in your application so you do not have to make any code changes.

1. In your pom.xml file, replace the log4j.jar dependency with a log4j-over-slf4j.jar dependency, and add the Logback dependencies:

  ```xml
  <dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>log4j-over-slf4j</artifactId>
    <version>1.7.32</version>
  </dependency>
  <dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.2.9</version>
  </dependency>
  <dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>6.6</version>
  </dependency>
  ```

2. Configure a file appender using the JSON layout in logback.xml

  ```xml
  <configuration>
    <appender name="FILE" class="ch.qos.logback.core.FileAppender">
      <file>logs/app.log</file>
      <encoder class="net.logstash.logback.encoder.LogstashEncoder" />
    </appender>

    <root level="INFO">
      <appender-ref ref="FILE"/>
    </root>
  </configuration>
  ```

[^19]: https://docs.datadoghq.com/tracing/other_telemetry/connect_logs_and_traces/
[^21]: https://docs.datadoghq.com/tracing/other_telemetry/connect_logs_and_traces/java
[^22]: https://docs.datadoghq.com/logs/log_collection/java/

### Observability Pipelines

Because your log volume grows as your organization scales, the cost of ingesting and indexing in your downstream services (for example, log management solutions, SIEMs, and so forth) also rises. This guide[^18] walks you through using Observability Pipelines’ transforms to cut down on log volume and trim down the size of your logs to control your costs before data leaves your infrastructure or network.

[^18]: https://docs.datadoghq.com/observability_pipelines/guide/control_log_volume_and_size

## Profiling in Java

Enable the profiler by setting ```-Ddd.profiling.enabled``` flag or ```DD_PROFILING_ENABLED``` environment variable to true. Specify ```dd.service```, ```dd.env```, and ```dd.version``` so you can filter and group your profiles across these dimensions

CPU profiler engine options:

Since ```dd-trace-java``` version ```1.5.0```, you have two options for the CPU profiler used, Datadog or Java Flight Recorder (JFR). Since version ```1.7.0```, Datadog is the default, but you can also optionally enable JFR for CPU profiling. You can enable either one or both engines. Enabling both captures both profile types at the same time.

The Datadog profiler records the active span on every sample, which improves the fidelity of the Code Hotspots and Endpoint profiling features. Enabling this engine supports much better integration with APM tracing. The Datadog profiler consists of several profiling engines, including CPU, wallclock, allocation, and memory leak profilers.

## Remote Configuration

Remote configuration[^26] is enabled by default in the Agent. Subsequently, we have opted to disable it in [datadog-agent-on-openshift.yaml](solution-2-operator/datadog-agent-on-openshift.yaml).

[^26]:(https://docs.datadoghq.com/agent/remote_config/)

## Advanced Prometheus autodiscovery configuration with Datadog agent (prometheusScrape)

MyOrg applications such as [Tibco BWCE deployed on OpenShift](https://git.internal.example.com/arquitectura/jenkins/jenkins2-scripts/-/blob/project-datadog-tibco/deployments/tibco-bwce_app_auth_ocp.yaml), have *Custom Prometheus Metrics* configured exposed on Pod port 9095 [Ref1](https://github.com/TIBCOSoftware/bw-tooling/tree/master/prometheus-integration), accessible outside the kubernetes cluster via a *Node Port* type *Service* on port 3185. We can access these metrics from our computer at http://192.168.1.100:31837/metrics

If we want to view these metrics in Datadog, the simplest way [Ref2](https://github.com/DataDog/datadog-operator/blob/main/examples/datadogagent/v2alpha1/datadog-agent-with-prometheus-autodiscovery-advanced-config.yaml), [Ref3](https://docs.datadoghq.com/containers/kubernetes/prometheus) would be through a configuration at the [Datadog Operator](datadog-agent-on-openshift.yaml) level like the following:

```yaml
    prometheusScrape:
      enabled: true
      enableServiceEndpoints: true
      additionalConfigs: |-
        - autodiscovery:
          kubernetes_annotations:
            include:
              app: tibco-bwce-arg-online
          kubernetes_container_names:
          - tibco-bwce-arg-online
        configurations:
        - send_distribution_buckets: true
          timeout: 5
```

On the other hand, it would be necessary to add the following configuration in the corresponding manifests of the POD Deployment and POD Service of the application that exposes the prometheus custom metrics:

```yaml
annotations: 
  prometheus.io/scrape: "true"
  prometheus.io/port: "31837"
```

## Kubernetes Control Plane Monitoring

This section allows viewing metrics in the following Datadog Dashboards:
- [Kubernetes API Server Overview](https://app.datadoghq.eu/dash/integration/555/kubernetes-api-server-overview)
- [Kubernetes Controller Manager Overview](https://app.datadoghq.eu/dash/integration/150/kubernetes-controller-manager-overview)

**Note:** We are trying to monitor our on-prem OpenShift with Datadog. It is not possible to view CPU & memory usage in the two dashboards indicated above, nor is it possible to view the Control Plane logs (Kubernetes Audit Logs). It is possible that in the future Datadog will publish specific Dashboards for OpenShift. It is very likely that those same metrics and logs will be viewed with other kubernetes clusters that we may incorporate in the future (such as GKE). This matter has been escalated to support:

```
Hi User,
__ 
I see, thanks for your message. To add some more background here, both the Kube API Server and Kube Controller Manager cpu/memory graphs query data from metrics like kubernetes.memory.requests, and kubernetes.cpu.requests, like in the attachedpicture. These metrics aren't collected outright from the Kube API Server check or the Kube Controller Manager check, but rather from the agent itself collecting kubernetes metrics on containers with images that match short_image:kube-apiserver orshort_image:kube-controller-manager: https://app.datadoghq.eu/notebook/notebook-id/datadog-support
__ 
This is also where the missing logs on these dashboards are supposed to come from - any logs from these container images are marked with a source:kube-apiserver or source:kube-controller-manager.
__ 
But, this Openshift 4 setup requires that the agent poll for these metrics at a specific endpoint with endpoint checks, rather than collecting these metrics from a running container. Because the agent can't poll a running kube-apiserver orkube-controller-manager container directly for this info, the agent can't collect these container level metrics like kubernetes.memory.requests. And in the same way, this endpoint also does not expose logs from these components, which is why theagent isn't able to collect any matching logs either.
__ 
With this in mind, it unfortunately is expected that this information isn't available in these dashboards, due to the fact that these control plane components must be monitored with endpoint checks in Openshift 4. 
__ 
Best regards,
Christian Ray | Solutions Engineer | Datadog
```

This section aims to document specificities and to provide good base configurations for monitoring the Kubernetes Control Plane. You can then customize these configurations to add any Datadog feature.

With Datadog integrations for the API server, Etcd, Controller Manager, and Scheduler, you can collect key metrics from all four components of the Kubernetes Control Plane[^31].

On OpenShift 4, all control plane components can be monitored using endpoint checks[^31].

Prerequisites: 
1. Enable the Datadog Cluster Agent
2. Enable Cluster checks
3. Enable Endpoint checks
4. Ensure that you are logged in with sufficient permissions to edit services and create secrets.

Endpoint check dispatching is enabled in the Operator deployment of the Cluster Agent by using the features.clusterChecks.enabled configuration key[^32].

[^31]: https://docs.datadoghq.com/containers/kubernetes/control_plane/?tab=operator#OpenShift4
[^32]: https://docs.datadoghq.com/containers/cluster_agent/endpointschecks/?tab=operator#set-up-endpoint-check-dispatching

### API Server

The API server runs behind the service kubernetes in the ```default``` namespace. Annotate this service with the ```kube_apiserver_metrics``` configuration:

```bash
oc annotate service kubernetes -n default 'ad.datadoghq.com/endpoints.check_names=["kube_apiserver_metrics"]'
oc annotate service kubernetes -n default 'ad.datadoghq.com/endpoints.init_configs=[{}]'
oc annotate service kubernetes -n default 'ad.datadoghq.com/endpoints.instances=[{"prometheus_url": "https://%%host%%:%%port%%/metrics", "bearer_token_auth": "true"}]'
oc annotate service kubernetes -n default 'ad.datadoghq.com/endpoints.resolve=ip'
```

The last annotation ```ad.datadoghq.com/endpoints.resolve``` is needed because the service is in front of static pods. The Datadog Cluster Agent schedules the checks as endpoint checks and dispatches them to Cluster Check Runners. 

### Etcd

Certificates are needed to communicate with the Etcd service, which can be found in the secret ```kube-etcd-client-certs``` in the ```openshift-monitoring``` namespace. To give the Datadog Agent access to these certificates, first copy them into the same namespace the Datadog Agent is running in:

```bash
oc get secret kube-etcd-client-certs -n openshift-monitoring -o yaml | sed 's/namespace: openshift-monitoring/namespace: openshift-operators/'  | oc create -f -
```

These certificates should be mounted on the Cluster Check Runner pods by adding the volumes and volumeMounts as below.

Note: Mounts are also included to disable the Etcd check autoconfiguration file packaged with the agent

```yaml
kind: DatadogAgent
apiVersion: datadoghq.com/v2alpha1
metadata:
  name: datadog
spec:
  override:
    clusterChecksRunner:
      containers:
        agent:
          volumeMounts:
            - name: etcd-certs
              readOnly: true
              mountPath: /etc/etcd-certs
            - name: disable-etcd-autoconf
              mountPath: /etc/datadog-agent/conf.d/etcd.d
      volumes:
        - name: etcd-certs
          secret:
            secretName: kube-etcd-client-certs
        - name: disable-etcd-autoconf
          emptyDir: {}
```

Then, annotate the service running in front of Etcd:

```bash
oc annotate service etcd -n openshift-etcd 'ad.datadoghq.com/endpoints.check_names=["etcd"]'
oc annotate service etcd -n openshift-etcd 'ad.datadoghq.com/endpoints.init_configs=[{}]'
oc annotate service etcd -n openshift-etcd 'ad.datadoghq.com/endpoints.instances=[{"prometheus_url": "https://%%host%%:%%port%%/metrics", "tls_ca_cert": "/etc/etcd-certs/etcd-client-ca.crt", "tls_cert": "/etc/etcd-certs/etcd-client.crt",
      "tls_private_key": "/etc/etcd-certs/etcd-client.key"}]'
oc annotate service etcd -n openshift-etcd 'ad.datadoghq.com/endpoints.resolve=ip'
```

The Datadog Cluster Agent schedules the checks as endpoint checks and dispatches them to Cluster Check Runners.

### Controller Manager

The Controller Manager runs behind the service ```kube-controller-manager``` in the ```openshift-kube-controller-manager``` namespace. Annotate the service with the check configuration:

```bash
oc annotate service kube-controller-manager -n openshift-kube-controller-manager 'ad.datadoghq.com/endpoints.check_names=["kube_controller_manager"]'
oc annotate service kube-controller-manager -n openshift-kube-controller-manager 'ad.datadoghq.com/endpoints.init_configs=[{}]'
oc annotate service kube-controller-manager -n openshift-kube-controller-manager 'ad.datadoghq.com/endpoints.instances=[{"prometheus_url": "https://%%host%%:%%port%%/metrics", "ssl_verify": "false", "bearer_token_auth": "true"}]'
oc annotate service kube-controller-manager -n openshift-kube-controller-manager 'ad.datadoghq.com/endpoints.resolve=ip'
```

The Datadog Cluster Agent schedules the checks as endpoint checks and dispatches them to Cluster Check Runners.

### Scheduler

The Scheduler runs behind the service scheduler in the ```openshift-kube-scheduler``` namespace. Annotate the service with the check configuration:

```bash
oc annotate service scheduler -n openshift-kube-scheduler 'ad.datadoghq.com/endpoints.check_names=["kube_scheduler"]'
oc annotate service scheduler -n openshift-kube-scheduler 'ad.datadoghq.com/endpoints.init_configs=[{}]'
oc annotate service scheduler -n openshift-kube-scheduler 'ad.datadoghq.com/endpoints.instances=[{"prometheus_url": "https://%%host%%:%%port%%/metrics", "ssl_verify": "false", "bearer_token_auth": "true"}]'
oc annotate service scheduler -n openshift-kube-scheduler 'ad.datadoghq.com/endpoints.resolve=ip'
```

The Datadog Cluster Agent schedules the checks as endpoint checks and dispatches them to Cluster Check Runners.

## Kubernetes Audit Logs. Activate log collection in kubernetes

Collect Kubernetes audit logs to track everything that happens inside your Kubernetes clusters, including every call made to the Kubernetes API by any service. This includes the control plane (built-in controllers, the scheduler), node daemons (the kubelet, kube-proxy, and others), cluster services (such as the cluster autoscaler), users making kubectl requests, and even the Kubernetes API itself.

With the Kubernetes audit logs integration, you can diagnose permission issues, identify RBAC policies that need to be updated, and track slow API requests that are impacting your whole cluster.

**Audit logs are disabled by default in Kubernetes [(but enabled in OpenShift)](https://docs.openshift.com/container-platform/4.13/security/audit-log-view.html).** To enable them in your API server configuration, specify an audit policy file path[^33].

**Activate log collection in kubernetes**: Collecting logs is not enabled by default in the Datadog Agent[^34]. If you are running the Agent in a Kubernetes or Docker environment, see the dedicated [Kubernetes Log Collection](https://docs.datadoghq.com/containers/kubernetes/log):

```bash
apiVersion: datadoghq.com/v2alpha1
kind: DatadogAgent
metadata:
  name: datadog
spec:
  global:
    credentials:
      apiKey: <DATADOG_API_KEY>

  features:
    logCollection:
      enabled: true
      containerCollectAll: true

```

[^33]: https://docs.datadoghq.com/integrations/kubernetes_audit_logs/
[^34]: https://docs.datadoghq.com/agent/logs/

## Datadog Wizard to configure the application container for APM with YAML

[This Datadog Wizard 🔥🔥](https://app.datadoghq.eu/apm/service-setup?architecture=container-based&collection=Helm%20Chart%20%28Recommended%29&environment=kubernetes&language=java&profiling=false) can help us configure our apps' manifests:
1. Inject the Datadog Library via the Datadog Admission Controller
2. Automatically Inject Trace and Span IDs into Logs. **Note: In MyOrg's case, it is not necessary to activate the ```DD_LOGS_INJECTION=true``` variable thanks to the automatic injection of the latest versions of Java tracer.**
3. Configure a sampling rate for your service
4. Continuous Profiler
5. Application Security Management

## References

- Datadog integration with OpenShift available in Datadog Web UI -> Integrations -> OpenShift: https://app.datadoghq.eu/integrations/openshift?category=Kubernetes
- [Limit data collection to a subset of containers only](https://docs.datadoghq.com/containers/guide/autodiscovery-management/)
- https://www.datadoghq.com/blog/monitor-kubernetes-docker
- [Datadog Agent Configuration on Kubernetes](https://docs.datadoghq.com/containers/kubernetes/configuration/?tab=datadogoperator)
- [Environment variables](https://docs.datadoghq.com/containers/docker/?tab=standard#environment-variables)
- [Getting Started with Tags 🔥](https://docs.datadoghq.com/getting_started/tagging/)
- [Blog: Unified Service Tagging](https://www.datadoghq.com/blog/unified-service-tagging)
- [Monitoring in the kubenetes era](https://www.datadoghq.com/blog/monitoring-kubernetes-era/)
- [Best practices for tagging your infrastructure and applications](https://www.datadoghq.com/blog/tagging-best-practices/)
- [Datadog API](https://docs.datadoghq.com/api/latest/)

### Kubernetes Security Context

- https://ibrahims.medium.com/security-context-kubernetes-9672ae2380f9
- https://kubernetes.io/docs/concepts/security/pod-security-admission/ 
- https://kubernetes.io/docs/concepts/security/pod-security-standards/

### Datadog Agent Helm Chart Installation

- https://docs.datadoghq.com/containers/kubernetes/distributions/?tab=helm#Openshift
- https://github.com/DataDog/helm-charts/tree/main/charts/datadog
- https://github.com/DataDog/helm-charts/blob/main/charts/datadog/values.yaml
- https://github.com/DataDog/helm-charts/tree/main/examples/datadog
- https://github.com/DataDog/helm-charts/blob/main/examples/datadog/agent_on_openshift_values.yaml
- https://artifacthub.io/packages/helm/datadog/datadog

### Datadog Billing

- [Containers Billing 🔥🔥🔥](https://docs.datadoghq.com/account_management/billing/containers/)

### Datadog Operator References

#### Datadog Operator Installation via OpenShift Marketplace

- https://github.com/DataDog/datadog-operator/blob/main/docs/install-openshift.md 🔥
- https://www.datadoghq.com/blog/openshift-monitoring-with-datadog/ 🔥🔥

#### Datadog Operator Helm Chart Installation

- https://docs.datadoghq.com/getting_started/containers/datadog_operator/
- https://github.com/DataDog/helm-charts/blob/main/charts/datadog-operator
- https://github.com/DataDog/helm-charts/blob/main/charts/datadog-operator/values.yaml
- https://artifacthub.io/packages/helm/datadog/datadog-operator

### Kubernetes APM with Datadog References

- [Datadog Kubernetes APM](https://docs.datadoghq.com/containers/kubernetes/apm/?tab=datadogadmissioncontroller#configure-your-application-pods-to-submit-traces-to-datadog-agent)
- [Application Instrumentation](https://docs.datadoghq.com/tracing/trace_collection/)
  - [*Tracing Java Applications*](https://docs.datadoghq.com/tracing/trace_collection/automatic_instrumentation/dd_libraries/java)
  - [Local Library Injection](https://docs.datadoghq.com/tracing/trace_collection/library_injection_local/?tab=kubernetes)
- [*Datadog Admission Controller*](https://docs.datadoghq.com/containers/cluster_agent/admission_controller/?tab=helm)
- https://www.datadoghq.com/blog/auto-instrument-kubernetes-tracing-with-datadog/
- [docs.datadoghq.com: Enable java admission controller 🔥](https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-admission-controller/)
- [Simplify production debugging with Datadog Exception Replay](https://www.datadoghq.com/blog/exception-replay-datadog/)

### Profiling vs Tracing

- [Why profiling should be part of regular software development workflow](https://medium.com/performance-engineering-for-the-ordinary-barbie/why-profiling-should-be-part-of-regular-software-development-workflow-8b19b7f52b38)
- https://www.jwhitham.org/2016/02/profiling-versus-tracing.html 🔥
- http://ipm-hpc.sourceforge.net/profilingvstracing.html
