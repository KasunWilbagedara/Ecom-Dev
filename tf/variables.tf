variable "mongo_url" {
  type    = string
  default = "mongodb://root:example@localhost:27017/ecommerce_db"
}

variable "jwt_secret" {
  type    = string
  default = "supersecret"
}

variable "admin_email" {
  type    = string
  default = "admin@example.com"
}

variable "admin_password" {
  type    = string
  default = "password123"
}
