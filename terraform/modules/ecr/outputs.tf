output "repository_url" {
  description = "Full ECR URL used in the Jenkinsfile (e.g. 123456789.dkr.ecr.eu-west-1.amazonaws.com/fincorp/finance-tracker)"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.this.name
}

output "registry_id" {
  description = "ECR registry ID (your AWS account ID)"
  value       = aws_ecr_repository.this.registry_id
}
