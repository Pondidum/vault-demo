data_dir = "/var/nomad"

client {
    enabled = true
}

server {
    enabled = true
    bootstrap_expect = 1
}

vault {
    enabled = true
    address = "http://localhost:8200"
    token = "VAULT_TOKEN"
}
