output "jenkins_public_ip" {
  description = "Jenkins public IP address"
  value       = module.jenkins.public_ip
}

output "jenkins_url" {
  description = "Jenkins UI — open this in your browser after the instance boots (~3 min)"
  value       = "http://${module.jenkins.public_ip}:8080"
}

output "ecr_repository_url" {
  description = "Full ECR URL — set as ECR_REPO in the Jenkinsfile"
  value       = module.ecr.repository_url
}

output "codeartifact_domain" {
  description = "CodeArtifact domain name — used in Jenkinsfile aws codeartifact commands"
  value       = module.codeartifact.domain_name
}

output "codeartifact_domain_owner" {
  description = "CodeArtifact domain owner (AWS account ID)"
  value       = module.codeartifact.domain_owner
}

output "codeartifact_repository" {
  description = "CodeArtifact main repository name — Jenkins points npm at this"
  value       = module.codeartifact.main_repository
}

output "rds_endpoint" {
  description = "RDS connection endpoint (host:port) — use in app environment variables"
  value       = module.rds.db_endpoint
}

output "rds_arn" {
  description = "RDS instance ARN"
  value       = module.rds.db_arn
}

output "backup_vault_name" {
  description = "Primary backup vault name"
  value       = module.backup.vault_name
}
