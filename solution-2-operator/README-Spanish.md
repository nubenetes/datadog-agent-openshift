# Solución 2. Datadog Operator en OpenShift

1. [Introducción](#introducción)
2. [Datadog Operator vs. Helm chart](#datadog-operator-vs-helm-chart)
3. [Requisitos](#requisitos)
4. [Procedimiento de instalación de Datadog Operator](#procedimiento-de-instalación-de-datadog-operator)
   1. [Opción 1. Instalación de Datadog Operator via OpenShift Marketplace](#opción-1-instalación-de-datadog-operator-via-openshift-marketplace)
   2. [Opción 2. Instalación y actualización de Datadog Operator via Helm Chart](#opción-2-instalación-y-actualización-de-datadog-operator-via-helm-chart)
   3. [Opción 3. Instalación y actualización de Datadog Operator via Operator Lifecycle Manager](#opción-3-instalación-y-actualización-de-datadog-operator-via-operator-lifecycle-manager)
5. [Procedimiento de instalación y actualización de Datadog Agent Manifest](#procedimiento-de-instalación-y-actualización-de-datadog-agent-manifest)
6. [Referencias](#referencias)

## Introducción

Procedimiento de instalación y configuración de [**Datadog Operator**](https://operatorhub.io/operator/datadog-operator) que automáticamente gestiona **Datadog Agent** en Openshift.

## Datadog Operator vs. Helm chart

You can also use official Datadog Helm chart or a DaemonSet to install the Datadog Agent on Kubernetes. However, using the Datadog Operator offers the following advantages:

- The Operator has built-in defaults based on Datadog best practices.
- Operator configuration is more flexible for future enhancements.
- As a Kubernetes Operator, the Datadog Operator is treated as a first-class resource by the Kubernetes API.
- Unlike the Helm chart, the Operator is included in the Kubernetes reconciliation loop.

Datadog fully supports using a DaemonSet to deploy the Agent, but manual DaemonSet configuration leaves significant room for error. Therefore, using a DaemonSet is not highly recommended.

## Requisitos

- Cuenta de usuario en Datadog Cloud con API-Key (obligatorio) y app-key (opcional)

## Procedimiento de instalación de Datadog Operator

Existen tres métodos de instalación:
1. [ ] Mediante Openshift Marketplace, con Datadog Operator siendo instalado en *openshift-operators* namespace.
2. [ ] Mediante Datadog Operator Helm Chart, con Datadog Operator siendo instalado en *datadog* namespace (por ejemplo).
3. [x] Mediante Operator Lifecycle Manager (OLM). **Éste es el método de instalación implementado en MyOrg.**

### Opción 1. Instalación de Datadog Operator via OpenShift Marketplace

Desplegamos con 1 click el *Datadog Operator* disponible en OpenShift Marketplace y creamos un secreto en kubernetes con el API Key de Datadog:

1. [*Deploy the Datadog Operator in an OpenShift cluster*](https://github.com/DataDog/datadog-operator/blob/main/docs/install-openshift.md)
2. ```oc create secret -n openshift-operators generic datadog-secret --from-literal api-key=<> --from-literal app-key=<>```

### Opción 2. Instalación y actualización de Datadog Operator via Helm Chart

Creamos un secreto en kubernetes con el API Key de Datadog y desplegamos el Helm Chart de [Datadog Operator](https://operatorhub.io/operator/datadog-operator) con el siguiente [values.yaml](datadog-operator-helm-chart/values.yaml):

1. ```oc create secret -n openshift-operators generic datadog-secret --from-literal api-key=<> --from-literal app-key=<>```
4. ```helm install datadog-operator datadog/datadog-operator -n openshift-operators -f ./values.yaml```
5. ```helm ls -A```

Actualización de Datadog Operator via Helm Chart:

```helm upgrade datadog-operator datadog/datadog-operator -n openshift-operators -f ./values.yaml```

Desinstalación de Datadog Operator via Helm Chart:

```helm uninstall datadog-operator -n openshift-operators```

### Opción 3. Instalación y actualización de Datadog Operator via Operator Lifecycle Manager

Creamos un secreto en kubernetes con el API Key de Datadog y desplegamos [Datadog Operator](https://operatorhub.io/operator/datadog-operator) via [Operator Lifecycle Manager](https://github.com/DataDog/datadog-operator/blob/main/docs/installation.md#install-the-datadog-operator-with-operator-lifecycle-manager) via el manifiesto de subscripción al operador de datadog [olm.yaml](datadog-operator-helm-chart/olm.yaml):

1. ```oc create secret -n openshift-operators generic datadog-secret --from-literal api-key=<> --from-literal app-key=<>```
2. ```oc apply -f operatorhubio-catalog.yaml```
3. ```oc get catalogsource -A```
4. ```oc apply -f datadog-olm.yaml```
5. ```oc get subs -A```
6. ```oc get csv -n openshift-operators```

![datadog-operator-olm-1.png](../images/datadog-operator-olm-1.png)
![datadog-operator-olm-2.png](../images/datadog-operator-olm-2.png)
![datadog-operator-olm-3.png](../images/datadog-operator-olm-3.png)

## Procedimiento de instalación y actualización de Datadog Agent Manifest

Una vez hemos instalado Datadog Operator con uno de los dos métodos existentes, podemos proceder a desplegar el Agente de Datadog mediante el manifiesto [datadog-agent-on-openshift.yaml](datadog-agent-on-openshift.yaml) que hace uso de los CRDs creados por el operador:

```oc apply -f ./datadog-agent-on-openshift.yaml```

Posteriormente será necesario aplicar el siguiente manifiesto [scc.yaml](scc.yaml) de clase *SecurityContextConstraints* para habilitar el conjunto completo de características del Agente de Datadog.

```oc apply -f scc.yaml```

Desinstalación:

```oc delete -f ./datadog-agent-on-openshift.yaml; oc delete -f scc.yaml```

## Referencias

- https://docs.datadoghq.com/getting_started/containers/datadog_operator/
- https://artifacthub.io/packages/helm/datadog/datadog-operator
- https://github.com/DataDog/helm-charts/blob/main/charts/datadog-operator/values.yaml
- https://operatorhub.io/operator/datadog-operator
