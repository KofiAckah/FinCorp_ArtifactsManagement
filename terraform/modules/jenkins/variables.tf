variable "name" {
  description = "Name prefix for all Jenkins resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC to place Jenkins in"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID for the Jenkins EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 key pair name for SSH (leave empty to launch without a key)"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs permitted to SSH on port 22"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to every resource in this module"
  type        = map(string)
  default     = {}
}
