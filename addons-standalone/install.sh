


kubectl create namespace istio-system
kubectl create secret tls addon-certificates --key server-qcloud.key --cert server-qcloud.pem


# install istiod

# edit cm/istio 
# use /dev/stdout
# restart istio-ingress-gateway




cd chart
helm dependency build .



kubectl apply -f ./keycloak/gw.yaml
kubectl apply -f ./keycloak/vs.yaml

# update DNS settings


helm template addons -n istio-system ./chart -f ./values.yaml > gatekeeper/.addons-install-pre.yaml

kubectl kustomize ./gatekeeper > gatekeeper/.addons-install-post.yaml

kubectl apply -f gatekeeper/.addons-install-post.yaml



# create keycloak client: kiali-client, grafana-client, jaeger-client
    # Access Type: confidential
    # Mappers: audiences/groups  (required claim name: groups)
# create user/group
    # user: basic
    # groups: kiali_users, grafana_users, jaeger_users

# edit cm/oauth-proxy-gatekeeper-config: use correct client-secret
# restart pods: grafana/kiali/jaeger
# edit svc, add proxy port 8000: grafana/kiali/jaeger
# k apply gw/vs: grafana/kiali/jaeger

# grafana 可能不需要 gatekeeper!