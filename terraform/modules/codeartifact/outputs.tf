output "domain_name" {
  description = "CodeArtifact domain name"
  value       = aws_codeartifact_domain.this.domain
}

output "domain_owner" {
  description = "AWS account ID that owns the domain (needed for CLI commands)"
  value       = aws_codeartifact_domain.this.owner
}

output "npm_store_repository" {
  description = "Name of the public:npmjs upstream proxy repository"
  value       = aws_codeartifact_repository.npm_store.repository
}

output "main_repository" {
  description = "Name of the main repository (what Jenkins points npm at)"
  value       = aws_codeartifact_repository.main.repository
}
