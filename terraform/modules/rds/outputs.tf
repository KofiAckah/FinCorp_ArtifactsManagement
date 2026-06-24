output "db_endpoint" {
  description = "RDS connection endpoint (host:port) for the app"
  value       = aws_db_instance.this.endpoint
}

output "db_arn" {
  description = "RDS instance ARN — passed to the backup module's resource selection"
  value       = aws_db_instance.this.arn
}

output "db_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.identifier
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}
