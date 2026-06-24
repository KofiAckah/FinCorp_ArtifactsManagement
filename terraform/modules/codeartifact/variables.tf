variable "domain_name" {
  description = "CodeArtifact domain name (lowercase letters, numbers, hyphens only)"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource in this module"
  type        = map(string)
  default     = {}
}
