provider "docker" {}

resource "docker_image" "sql_server" {
  name = "mcr.microsoft.com/mssql/server:2019-latest"
}

resource "docker_container" "sql" {
  name  = "sql_container"
  image = docker_image.sql_server.image_id
  env = [
    "ACCEPT_EULA=Y",
    "SA_PASSWORD=StrongP@ssw0rd",
    "MSSQL_PID=Developer"
  ]
  ports {
    internal = 1433
    external = 1433
  }
}
