variable "name" {
  description = "ECR repository name (e.g. fincorp/finance-tracker)"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource in this module"
  type        = map(string)
  default     = {}
}
