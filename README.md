




# On KeyCloak:

### create realm 'mesh'

### create keycloak client: kiali-client, grafana-client, jaeger-client
    # Access Type: confidential
    # Mappers: audiences/groups  (required claim name: groups)
### create user/group
    # user: basic
    # groups: kiali_users, jaeger_users, grafana_users/grafana_admins





### todo: to use different deployment to support kiali viewer/admin




Keycloak warning:

the receive buffer of socket ManagedMulticastSocketBinding was set to 25.00MB, but the OS only allocated 16.78MB
