terraform {
  backend "s3" {
    bucket       = "fincorp-terraform-state-livingstone-nsp"
    key          = "primary/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
