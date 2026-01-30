# Docker network
resource "docker_network" "ecommerce_network" {
  name   = "ecommerce-network"
  driver = "bridge"
}

# MongoDB container
resource "docker_container" "mongo" {
  name    = "ecommerce-mongo"
  image   = "mongo:7.0"
  restart = "always"

  networks_advanced {
    name = docker_network.ecommerce_network.name
  }

  env = [
    "MONGO_INITDB_ROOT_USERNAME=root",
    "MONGO_INITDB_ROOT_PASSWORD=example",
    "MONGO_INITDB_DATABASE=ecommerce_db"
  ]

  ports {
    internal = 27017
    external = 27017
  }

  volumes {
    host_path      = var.mongo_data_path
    container_path = "/data/db"
  }
}

# Backend image and container
resource "docker_image" "backend" {
  name = "kasunwilbagedara/ecom_devops-backend:latest"

  build {
    context    = "../backend"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "backend" {
  name  = "ecommerce-backend"
  image = docker_image.backend.latest

  ports {
    internal = 5000
    external = 5000
  }

  depends_on = [docker_container.mongo]

  networks_advanced {
    name = docker_network.ecommerce_network.name
  }

  env = [
    "MONGO_URL=${var.mongo_url}",
    "JWT_SECRET=${var.jwt_secret}",
    "ADMIN_EMAIL=${var.admin_email}",
    "ADMIN_PASSWORD=${var.admin_password}"
  ]
}

# Frontend image and container
resource "docker_image" "frontend" {
  name = "kasunwilbagedara/ecom_devops-frontend:latest"

  build {
    context    = "../frontend"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "frontend" {
  name  = "ecommerce-frontend"
  image = docker_image.frontend.latest

  ports {
    internal = 5173
    external = 80
  }

  depends_on = [docker_container.backend]

  networks_advanced {
    name = docker_network.ecommerce_network.name
  }
}

# Admin image and container
resource "docker_image" "admin" {
  name = "kasunwilbagedara/ecom_devops-admin:latest"

  build {
    context    = "../admin"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "admin" {
  name  = "ecommerce-admin"
  image = docker_image.admin.latest

  ports {
    internal = 5174
    external = 8090
  }

  depends_on = [docker_container.backend]

  networks_advanced {
    name = docker_network.ecommerce_network.name
  }
}
