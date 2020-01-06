#!/bin/bash -eux

# enable AppRole backend
vault auth enable approle

read -n 1 -s -r

# ci could read the policies and update vault (after PR, of course...)
vault write auth/approle/role/demo_service \
    token_ttl=20m \
    token_max_ttl=1h \
    policies="default, postgres_connector"

read -n 1 -s -r

# read the generated role_id:
vault read auth/approle/role/demo_service/role-id

read -n 1 -s -r

# create a secret id for the instance of the application
vault write -f auth/approle/role/demo_service/secret-id
