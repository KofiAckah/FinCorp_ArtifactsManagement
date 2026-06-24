variable "aws_region" {
  description = "AWS region for the DR environment"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Project name prefix"
  type        = string
  default     = "fincorp"
}

variable "environment" {
  description = "Environment label"
  type        = string
  default     = "dr"
}
