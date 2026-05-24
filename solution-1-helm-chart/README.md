# Solution 1. Datadog Agent Helm Chart

> [!IMPORTANT]
> **Spanish Version / Versión en Español**:
> Este repositorio cuenta con una versión original en español redactada manualmente sin el uso de IA: [README-Spanish.md](README-Spanish.md).
>
> **English Version**:
> This English documentation (`README.md`) is a translation of the original Spanish version.

---

1. [Introduction](#introduction)
2. [Datadog Agent Helm Chart values.yaml](#datadog-agent-helm-chart-valuesyaml)
3. [Installation Procedure](#installation-procedure)
4. [Update Procedure](#update-procedure)

## Introduction

Procedure for installing and configuring the **Datadog Agent** on OpenShift using [Helm](https://helm.sh/).

## Datadog Agent Helm Chart values.yaml

OpenShift comes with hardened security by default (SELinux SecurityContextConstraints), [thus requiring some specific configuration](https://docs.datadoghq.com/containers/kubernetes/distributions/?tab=helm#Openshift):

- Create SCC for Node Agent and Cluster Agent
- Specific CRI socket path as OpenShift uses CRI-O container runtime
- Kubelet API certificates may not always be signed by cluster CA
- Tolerations are required to schedule the Node Agent on master and infra nodes
- Cluster name should be set as it cannot be retrieved automatically from cloud provider

[This helm configuration](https://docs.datadoghq.com/containers/kubernetes/distributions/?tab=helm#Openshift) in [values.yaml](values.yaml) supports OpenShift 3.11 and OpenShift 4, but works best with OpenShift 4:

```yaml
datadog:
  apiKey: <DATADOG_API_KEY>
  appKey: <DATADOG_APP_KEY>
  clusterName: <CLUSTER_NAME>
  criSocketPath: /var/run/crio/crio.sock
  # Depending on your DNS/SSL setup, it might not be possible to verify the Kubelet cert properly
  # If you have proper CA, you can switch it to true
  kubelet:
    tlsVerify: false
agents:
  podSecurity:
    securityContextConstraints:
      create: true
  tolerations:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
    operator: Exists
  - effect: NoSchedule
    key: node-role.kubernetes.io/infra
    operator: Exists
clusterAgent:
  podSecurity:
    securityContextConstraints:
      create: true
kube-state-metrics:
  securityContext:
    enabled: false
```

## Installation Procedure

1. ```helm repo add datadog https://helm.datadoghq.com```
2. ```helm repo update```
3. ```oc create secret -n datadog generic datadog-secret --from-literal api-key=<> --from-literal app-key=<>```
4. ```helm install datadog datadog/datadog -n datadog -f values.yaml```
5. ```oc apply -f scc.yaml```

## Update Procedure

1. ```helm upgrade datadog datadog/datadog -n datadog -f values.yaml```
