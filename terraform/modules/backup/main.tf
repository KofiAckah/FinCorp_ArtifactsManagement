resource "aws_backup_vault" "this" {
  name = var.vault_name
  tags = var.tags
}

# ── IAM role for the AWS Backup service (primary only) ───────────────────────

resource "aws_iam_role" "backup" {
  count = var.create_plan ? 1 : 0
  name  = "${var.vault_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  count      = var.create_plan ? 1 : 0
  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  count      = var.create_plan ? 1 : 0
  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# ── Backup plan (primary only) ────────────────────────────────────────────────

resource "aws_backup_plan" "this" {
  count = var.create_plan ? 1 : 0
  name  = "${var.vault_name}-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.this.name
    schedule          = "cron(0 2 * * ? *)"

    lifecycle {
      delete_after = 35
    }

    copy_action {
      destination_vault_arn = var.dr_vault_arn

      lifecycle {
        delete_after = 90
      }
    }
  }

  tags = var.tags
}

resource "aws_backup_selection" "this" {
  count = var.create_plan ? 1 : 0

  name         = "${var.vault_name}-selection"
  iam_role_arn = aws_iam_role.backup[0].arn
  plan_id      = aws_backup_plan.this[0].id
  resources    = var.protected_resource_arns
}
