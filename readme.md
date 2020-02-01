# Vault Demo

Repository to go with my talk on [How to Secure Your Microservices](https://andydote.co.uk/presentations/index.html?vault).

## Required Tools:

* Vagrant
* Vault client
* dotnet, if you want to run the sample apps
* Nomad client, if you want to try the ExternalConfigured app

## Setup:

1. `vagrant up`
1. `source .machine/env` - sets environment variables for Nomad, Vault etc.
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
1. `ExternalConfiguration`
    * Deploy with nomad (`nomad job run apps/external.nomad`)
    * Uses Nomad's Vault integration to prepopulate environment variables

