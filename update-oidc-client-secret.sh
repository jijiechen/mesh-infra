#!/bin/bash

set -e



OIDC_CLIENT_ID=$1
OIDC_CLIENT_SECRET=$2


if [ -z "$OIDC_CLIENT_ID" ]; then
    echo "OIDC_CLIENT_ID is not set as parameter 1."
    exit 1
fi
if [ -z "$OIDC_CLIENT_SECRET" ]; then
    echo "OIDC_CLIENT_SECRET is not set as parameter 2."
    exit 1
fi


k get cm/addons-grafana -o yaml |sed 's/OIDC_CLIENT_ID/$OIDC_CLIENT_ID/' | sed 's/OIDC_CLIENT_SECRET/$OIDC_CLIENT_SECRET/' | k apply -f -
k get cm/addons-oidc-gatekeeper-config -o yaml | \
    sed 's/OIDC_CLIENT_ID/$OIDC_CLIENT_ID/' | \
    sed 's/OIDC_CLIENT_SECRET/$OIDC_CLIENT_SECRET/' | \
    k apply -f - 

kubectl rollout restart deployment/addons-grafana
kubectl rollout restart deployment/addons-jaeger-query
kubectl rollout restart deployment/addons-kiali
