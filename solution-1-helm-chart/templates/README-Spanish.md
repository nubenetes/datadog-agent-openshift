# Ficheros de Plantillas

1. [Ficheros de Helm del Operador de Datadog](datadog-operator-helm-chart/README.md)
2. [values-experimental.yaml](values-experimental.yaml): 
    - Mi propio fichero experimental con configuraciones personalizadas como ntp
3. [values-with-lib-conf.yaml (**no recomendado**)](values-with-lib-conf.yaml): 
    - Fichero de valores con configuración de librería. 
    - Referencia: https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-admission-controller/
    - Fichero de origen: https://github.com/DataDog/springblog/blob/main/k8s/depl-with-lib-conf.yaml
4. [values-with-lib-inj.yaml (**usar este**)](values-with-lib-inj.yaml): 
    - Fichero de valores con inyección de librería. 
    - Referencia: https://docs.datadoghq.com/tracing/guide/tutorial-enable-java-admission-controller/
    - Fichero de origen: https://github.com/DataDog/springblog/blob/main/k8s/depl-with-lib-inj.yaml
