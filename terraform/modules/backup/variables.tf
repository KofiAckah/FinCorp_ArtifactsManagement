variable "vault_name" {
  description = "Name of the backup vault"
  type        = string
}

variable "create_plan" {
  description = "Set to true in primary to create the plan + selection; false in DR (vault only)"
  type        = bool
  default     = false
}

variable "dr_vault_arn" {
  description = "ARN of the DR vault to copy snapshots to (required when create_plan = true)"
  type        = string
  default     = ""
}

variable "protected_resource_arns" {
  description = "ARNs of resources to include in the backup selection"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to every resource in this module"
  type        = map(string)
  default     = {}
}
