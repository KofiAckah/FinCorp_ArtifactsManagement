output "dr_vault_arn" {
  description = "Copy this value into environments/primary/terraform.tfvars as dr_vault_arn"
  value       = module.backup_vault.vault_arn
}

output "dr_vpc_id" {
  description = "VPC ID in the DR region"
  value       = module.vpc.vpc_id
}

output "dr_subnet_ids" {
  description = "Private subnet IDs available for an RDS restore"
  value       = module.vpc.private_subnet_ids
}

output "dr_restore_subnet_group" {
  description = "DB subnet group name to specify when restoring RDS in the DR region"
  value       = aws_db_subnet_group.dr_restore.name
}
