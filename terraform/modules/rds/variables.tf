variable "name" {
  description = "Identifier prefix for RDS and related resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the DB subnet group (at least 2 required)"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group ID allowed to reach port 5432 (Jenkins/app SG)"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "fincorp"
}

variable "db_username" {
  description = "Master DB username"
  type        = string
  default     = "fincorp_user"
}

variable "db_password" {
  description = "Master DB password"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "tags" {
  description = "Tags applied to every resource in this module"
  type        = map(string)
  default     = {}
}
