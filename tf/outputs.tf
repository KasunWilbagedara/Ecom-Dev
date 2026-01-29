output "mongo_container_id" {
  value = docker_container.mongo.id
}

output "backend_container_id" {
  value = docker_container.backend.id
}

output "frontend_container_id" {
  value = docker_container.frontend.id
}

output "admin_container_id" {
  value = docker_container.admin.id
}
