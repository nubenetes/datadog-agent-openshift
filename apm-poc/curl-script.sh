#!/bin/bash

for i in {1..1000}; do
    echo "$i"
    curl http://springfront-datadog-demo.apps.cluster.example.com/upstream
done