output "public_ip" {
  description = "Jenkins public IP — open http://<ip>:8080 in your browser"
  value       = aws_instance.jenkins.public_ip
}

output "instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = aws_instance.jenkins.id
}

output "security_group_id" {
  description = "Jenkins security group ID — passed to RDS to allow DB access"
  value       = aws_security_group.jenkins.id
}
