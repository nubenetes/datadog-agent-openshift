# Solución 1. Helm Chart de Datadog Agent

1. [Introducción](#introducción)
2. [Helm Chart values.yaml para Datadog Agent](#helm-chart-valuesyaml-para-datadog-agent)
3. [Procedimiento de instalación](#procedimiento-de-instalación)
4. [Procedimiento de actualización](#procedimiento-de-actualización)

## Introducción

Procedimiento de instalación y configuración de **Datadog Agent** en Openshift con [Helm](https://helm.sh/).

## Helm Chart values.yaml para Datadog Agent

OpenShift comes with hardened security by default (SELinux  SecurityContextConstraints), [thus requiring some specific configuration](https://docs.datadoghq.com/containers/kubernetes/distributions/?tab=helm#Openshift):

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

## Procedimiento de instalación

1. ```helm repo add datadog https://helm.datadoghq.com```
2. ```helm repo update```
3. ```oc create secret -n datadog generic datadog-secret --from-literal api-key=<> --from-literal app-key=<>```
4. ```helm install datadog datadog/datadog -n datadog -f values.yaml```
5. ```oc apply -f scc.yaml```

## Procedimiento de actualización

1. ```helm upgrade datadog datadog/datadog -n datadog -f values.yaml```
