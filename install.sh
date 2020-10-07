#!/bin/bash

set -e

# Requirements:
# istioctl   = v1.7.0
# kubectl  > v1.16
# helm     > v3

WILDCARD_BASE_DOMAIN=$1
if [ -z "$WILDCARD_BASE_DOMAIN" ]; then
    echo "Please specify the base domain for the wildcard domain as argument 1."
    exit 1
fi

KUBECTL_CMD=$(command -v kubectl)
if [ -z "$KUBECTL_CMD" ]; then
    echo "kubectl is not installed."
    exit 1
fi

ISTIOCTL_CMD=$(command -v istioctl)
if [ -z "$ISTIOCTL_CMD" ]; then
    echo "istioctl is not installed."
    exit 1
fi

HELM_CMD=$(command -v helm)
if [ -z "$HELM_CMD" ]; then
    echo "helm is not installed."
    exit 1
fi



echo "Please confirm a wildcard certificate is made for *.$WILDCARD_BASE_DOMAIN"
until [[ $CONFIRM =~ ^[Y]$ ]]; do
    read -rp "Type Y to continue: " -e CONFIRM
done
CONFIRM=

sed -i '' "s/WILDCARD_BASE_DOMAIN/$WILDCARD_BASE_DOMAIN/" ./addons/mesh/*
sed -i '' "s/WILDCARD_BASE_DOMAIN/$WILDCARD_BASE_DOMAIN/" ./addons/gatekeeper/configmap/*
sed -i '' "s/WILDCARD_BASE_DOMAIN/$WILDCARD_BASE_DOMAIN/" ./addons/chart/values.yaml

echo "Installing Istiod..."
istioctl install -f ./istio-operator.yaml -n istio-system


echo "Installing KeyCloak..."
kubectl create secret tls addons-certificates --key certs/server/server.key --cert certs/server/server.pem -n istio-system

helm install addons-keycloak -n istio-system ./addons/chart \
    --set-string 'switches.keycloak-enabled=true' --wait --timeout 5m
kubectl apply -f ./addons/mesh/keycloak.gw.yaml -n istio-system
kubectl apply -f ./addons/mesh/keycloak.vs.yaml -n istio-system

sleep 5
echo ""
INGRESS_IP=$(kubectl get svc/istio-ingressgateway -o 'jsonpath={.status.loadBalancer.ingress[0].ip}')
echo "Ingress gateway IP is $INGRESS_IP"
echo "Keycloak hostname: keycloak.$WILDCARD_BASE_DOMAIN"
echo "Please update DNS and create oidc clients in KeyCloak:"
echo "DNS: *.$WILDCARD_BASE_DOMAIN"
echo "IP:  $INGRESS_IP"
echo "======================"
echo ""





echo "Please confirm you've updated your DNS"
until [[ $CONFIRM =~ ^[Y]$ ]]; do
    read -rp "Type Y to continue: " -e CONFIRM
done
CONFIRM=
echo "Installing mesh addons..."

helm template addons -n istio-system ./addons/chart \
    --set-string 'switches.prometheus-enabled=true,switches.grafana-enabled=true,switches.kiali-enabled=true,switches.jaeger-enabled=true' \
    > ./addons/gatekeeper/.addons-install-pre.yaml
kubectl kustomize ./addons/gatekeeper > ./addons/gatekeeper/.addons-install-post.yaml
kubectl apply  -n istio-system -f ./addons/gatekeeper/.addons-install-post.yaml

sleep 3
kubectl rollout status deploy/addons-kiali -n istio-system
kubectl rollout status deploy/addons-grafana -n istio-system
kubectl rollout status deploy/addons-jaeger-query -n istio-system


for SVC in grafana kiali jaeger ; do
    kubectl apply -f ./addons/mesh/$SVC.gw.yaml -n istio-system
    kubectl apply -f ./addons/mesh/$SVC.vs.yaml -n istio-system
done



echo -e "\e[1;32mInstallation has completed successfully.\e[0m"
echo "Please run 'update-oidc-client-secret.sh' to set oidc client secrets after these clients are created in KeyCloak."

