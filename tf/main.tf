# --------------------------
# Docker Network
# --------------------------
resource "docker_network" "ecommerce_network" {
  name          = "ecommerce-network"
  driver        = "bridge"
  force_destroy = true   # removes existing network if it exists
}

# --------------------------
# MongoDB Container
# --------------------------
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

# --------------------------
# Backend Image & Container
# --------------------------
resource "docker_image" "backend" {
  name = "kasunwilbagedara/ecom_devops-backend:latest"

  build {
    context    = "../backend"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "backend" {
  name  = "ecommerce-backend"
  image = docker_image.backend.name

  depends_on = [docker_container.mongo]

  ports {
    internal = 5000
    external = 5000
  }

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

# --------------------------
# Frontend Image & Container
# --------------------------
resource "docker_image" "frontend" {
  name = "kasunwilbagedara/ecom_devops-frontend:latest"

  build {
    context    = "../frontend"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "frontend" {
  name  = "ecommerce-frontend"
  image = docker_image.frontend.name

  depends_on = [docker_container.backend]

  ports {
    internal = 5173
    external = 80
  }

  networks_advanced {
    name = docker_network.ecommerce_network.name
  }
}

# --------------------------
# Admin Image & Container
# --------------------------
resource "docker_image" "admin" {
  name = "kasunwilbagedara/ecom_devops-admin:latest"

  build {
    context    = "../admin"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "admin" {
  name  = "ecommerce-admin"
  image = docker_image.admin.name

  depends_on = [docker_container.backend]

  ports {
    internal = 5174
    external = 8090
  }

  networks_advanced {
    name = docker_network.ecommerce_network.name
  }
}
