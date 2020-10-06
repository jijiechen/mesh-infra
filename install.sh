#!/bin/bash

set -e

# Requirements:
# istioctl   = v1.7.0
# kubectl  > v1.16
# helm     > v3

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

INGRESS_GATEWAY_ZHIYAN_LOG_NAME=$1
if [ -z "$INGRESS_GATEWAY_ZHIYAN_LOG_NAME" ]; then
    echo "Please use parameter 1 to specify zhiyan log name for ingress gateway access log as:"
    echo "install.sh <logname>"
    exit 1
fi

LINE_BREAK=$'\n'
cp istio-operator-overrides/configmap.zhiyan-integration.yaml istio-operator-overrides/.istio-install-manifest-configmap.zhiyan-integration.yaml
echo "  log-name: $INGRESS_GATEWAY_ZHIYAN_LOG_NAME$LINE_BREAK" >> istio-operator-overrides/.istio-install-manifest-configmap.zhiyan-integration.yaml

# Build
istioctl manifest generate -f ./istio-operator-config.yaml > istio-operator-overrides/.istio-install-manifest-pre.yaml
# kubectl kustomize ./istio-operator-overrides > istio-operator-overrides/.istio-install-manifest-post.yaml

# Install 
CTX=$(kubectl config current-context)
CLUSTER=$(kubectl config view -o jsonpath="{.contexts[?(@.name == '$CTX')].context.cluster}")
CLUSTER_SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name == '$CLUSTER')].cluster.server}")
echo "Connecting to cluster '$CLUSTER' at $CLUSTER_SERVER"
kubectl cluster-info

echo "Installing resources..."
kubectl create namespace istio-system 2>/dev/null || true
kubectl apply -f istio-operator-overrides/.istio-install-manifest-pre.yaml
kubectl rollout status deployment/istiod -n istio-system
kubectl rollout status deployment/istio-ingressgateway -n istio-system

# Cleanup
ls -a istio-operator-overrides | grep '.istio-install-manifest' | xargs -I % rm -f istio-operator-overrides/%