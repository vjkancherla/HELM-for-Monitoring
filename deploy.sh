#!/bin/bash

echo "Adding Helm repo for Prometheus..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

echo "Creating Kubernetes namespace 'monitoring'..."
kubectl create ns monitoring

echo "Installing Prometheus using Helm..."
helm install my-prometheus prometheus-community/kube-prometheus-stack \
--namespace monitoring \
-f values-files/prometheus-values.yaml

echo "Adding Helm repo for Loki..."
helm repo add grafana https://grafana.github.io/helm-charts

echo "Installing Loki using Helm..."
helm install my-loki grafana/loki-stack \
--namespace monitoring \
-f values-files/loki-values.yaml

echo "Installing Grafana using Helm..."
helm install my-grafana grafana/grafana \
--namespace monitoring \
-f values-files/grafana-values.yaml

# Get the admin token from Grafana secret and decode it
GRAFANA_PASSWORD=$(kubectl get secret --namespace monitoring my-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

# Print the Grafana admin token
echo "Grafana Admin Token: $GRAFANA_PASSWORD"

echo "Installing Example App with Helm..."
helm install my-example-app ./Example-App/example-app-chart

echo "Port forwarding Prometheus..."
# Port forward Prometheus
kubectl port-forward -n monitoring svc/my-prometheus-kube-prometh-prometheus 9090:9090 &

echo "Port forwarding Grafana..."
# Port forward Grafana
kubectl port-forward -n monitoring svc/my-grafana 3000:80 &
