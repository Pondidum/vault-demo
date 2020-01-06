job "external" {
  datacenters = ["dc1"]
  type = "service"

  group "apps" {

    task "external_configured" {
      driver = "exec"

      config {
        command = "/usr/bin/dotnet"
        args = [
          "local/ExternalConfiguration.dll"
        ]
      }

      artifact {
        source = "http://artifacts.service.consul:3030/ExternalConfiguration.zip"
      }

      vault {
        policies = ["postgres_connector"]
      }

      template {
        data = <<EOF
{{ with service "postgres"}}{{ with index . 0 }}
DB_HOST={{ .Address }}
DB_PORT={{ .Port }}
{{ end }}{{ end }}

{{ with secret "database/creds/reader" }}
DB_USERNAME={{ .Data.username | toJSON }}
DB_PASSWORD={{ .Data.password | toJSON }}
{{ end }}
DB_DATABASE=postgres
        EOF
        destination = "secrets/file.env"
        env = true
      }

    }
  }
}