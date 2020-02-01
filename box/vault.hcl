backend "file" {
	path = "/var/vault"
}

ui = true

listener "tcp" {
	address = "0.0.0.0:8200"
	tls_disable = 1
}

