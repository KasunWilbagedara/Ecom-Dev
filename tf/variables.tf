variable "mongo_data_path" {
  description = "MongoDB data directory on host"
  type        = string
  default     = "/home/kasun/mongo-data"
}

variable "mongo_url" {
  default = "mongodb://root:example@ecommerce-mongo:27017/ecommerce_db"
}

variable "jwt_secret" {
  default = "supersecretjwt"
}

variable "admin_email" {
  default = "admin@example.com"
}

variable "admin_password" {
  default = "admin123"
}
