#!/bin/bash

set -e



# export GRAFANA_OIDC_CLIENT_SECRET=''
# export KIALI_OIDC_CLIENT_SECRET=''
# export JAEGER_OIDC_CLIENT_SECRET=''


if [ -z "$GRAFANA_OIDC_CLIENT_SECRET" ]; then
    echo "GRAFANA_OIDC_CLIENT_SECRET is not set."
    exit 1
fi
if [ -z "$KIALI_OIDC_CLIENT_SECRET" ]; then
    echo "KIALI_OIDC_CLIENT_SECRET is not set."
    exit 1
fi
if [ -z "$JAEGER_OIDC_CLIENT_SECRET" ]; then
    echo "JAEGER_OIDC_CLIENT_SECRET is not set."
    exit 1
fi


k get cm/addons-grafana -o yaml | sed "s/GGGGGGGG/$GRAFANA_OIDC_CLIENT_SECRET/" | k apply -f -
k get cm/addons-oidc-gatekeeper-config -o yaml | \
    sed 's/JJJJJJJJ/$JAEGER_OIDC_CLIENT_SECRET/' | \
    sed 's/KKKKKKKK/$KIALI_OIDC_CLIENT_SECRET/' | \
    k apply -f - 


PATCH="{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
kubectl patch deployment addons-grafana -p $PATCH
kubectl patch deployment addons-jaeger-query -p $PATCH
kubectl patch deployment addons-kiali -p $PATCH
