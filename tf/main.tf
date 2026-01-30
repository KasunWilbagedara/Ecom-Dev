# --------------------------
# Cleanup existing Docker resources
# --------------------------
resource "null_resource" "docker_cleanup" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Cleaning up old Docker resources..."

      # Stop and remove existing containers
      docker rm -f ecommerce-mongo ecommerce-backend ecommerce-frontend ecommerce-admin || true

      # Remove existing images
      docker rmi -f kasunwilbagedara/ecom_devops-backend:latest kasunwilbagedara/ecom_devops-frontend:latest kasunwilbagedara/ecom_devops-admin:latest || true

      echo "Cleanup complete."
    EOT
  }
}

# --------------------------
# MongoDB Container
# --------------------------
resource "docker_container" "mongo" {
  name    = "ecommerce-mongo"
  image   = "mongo:7.0"
  restart = "always"

  depends_on = [null_resource.docker_cleanup]

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

  depends_on = [null_resource.docker_cleanup]
}

resource "docker_container" "backend" {
  name  = "ecommerce-backend"
  image = docker_image.backend.name

  depends_on = [docker_container.mongo]

  ports {
    internal = 5000
    external = 5000
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

  depends_on = [null_resource.docker_cleanup]
}

resource "docker_container" "frontend" {
  name  = "ecommerce-frontend"
  image = docker_image.frontend.name

  depends_on = [docker_container.backend]

  ports {
    internal = 5173
    external = 80
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

  depends_on = [null_resource.docker_cleanup]
}

resource "docker_container" "admin" {
  name  = "ecommerce-admin"
  image = docker_image.admin.name

  depends_on = [docker_container.backend]

  ports {
    internal = 5174
    external = 8090
  }
}
