terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.16"
    }
  }
}



# Docker network
resource "docker_network" "ecommerce_network" {
  name   = "ecommerce-network"
  driver = "bridge"
}

# MongoDB container
resource "docker_container" "mongo" {
  image   = "mongo:7.0"
  name    = "ecommerce-mongo"
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
    host_path      = "${path.module}/mongo-data"
    container_path = "/data/db"
  }
}

# Backend container
resource "docker_container" "backend" {
  image = "kasunwilbagedara/ecom_devops-backend:latest"

  build {
    context = "../backend"
  }

  name = "ecommerce-backend"

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

# Frontend container
resource "docker_container" "frontend" {
  image = "kasunwilbagedara/ecom_devops-frontend:latest"

  build {
    context = "../frontend"
  }

  name = "ecommerce-frontend"

  ports {
    internal = 5173
    external = 80
  }

  depends_on = [docker_container.backend]

  networks_advanced {
    name = docker_network.ecommerce_network.name
  }
}

# Admin container
resource "docker_container" "admin" {
  image = "kasunwilbagedara/ecom_devops-admin:latest"

  build {
    context = "../admin"
  }

  name = "ecommerce-admin"

  ports {
    internal = 5174
    external = 8090
  }

  depends_on = [docker_container.backend]

  networks_advanced {
    name = docker_network.ecommerce_network.name
  }
}
