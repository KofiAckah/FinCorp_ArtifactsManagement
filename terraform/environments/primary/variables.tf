variable "aws_region" {
  description = "AWS region for the primary environment"
  type        = string
  default     = "eu-west-1"
}

variable "project" {
  description = "Project name prefix (used in all resource names)"
  type        = string
  default     = "fincorp"
}

variable "environment" {
  description = "Environment label"
  type        = string
  default     = "primary"
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for the Jenkins server"
  type        = string
  default     = "t3.medium"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_password" {
  description = "RDS master password — supply via TF_VAR_db_password, never commit plaintext"
  type        = string
  sensitive   = true
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access to Jenkins (leave empty to skip)"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed to SSH into Jenkins on port 22"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "dr_vault_arn" {
  description = "ARN of the DR backup vault — copy from `terraform output dr_vault_arn` in environments/dr"
  type        = string
}
