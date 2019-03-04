# Vault Demo

Repository to go with my talk on [How to Secure Your Microservices](https://andydote.co.uk/presentations/index.html?vault) (**not published yet**).

## Setup:

1. `docker-compose up -d`
1. `./init.sh` - writes services into Consul
1. `./postgres.sh` - sets up the database secrets engine
1. `./approles.sh` - creates the `demo_service` approle

## Apps

All apps just connect to postgres, and list all users/roles and their expiry times.

1. `DirectAccess`
    * uses vault master token
1. `AppRoleAccess`
    * uses a RoleID and SecretID.
    * Set `VaultRoleID` environment variable
    * Set `VaultSecretID` in the `appsettings.json`
1. `ServiceDiscoveryAccess`
    * uses Consul and RoleID and SecretID
    * Set `VaultRoleID` environment variable
    * Set `VaultSecretID` in the `appsettings.json`
