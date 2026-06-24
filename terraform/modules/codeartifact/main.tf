resource "aws_codeartifact_domain" "this" {
  domain = var.domain_name
  tags   = var.tags
}

# Proxies public npmjs.com — all npm installs are cached here
resource "aws_codeartifact_repository" "npm_store" {
  repository = "${var.domain_name}-npm-store"
  domain     = aws_codeartifact_domain.this.domain

  external_connections {
    external_connection_name = "public:npmjs"
  }

  tags = var.tags
}

# Main repo Jenkins configures npm against — pulls through npm-store upstream
resource "aws_codeartifact_repository" "main" {
  repository = "${var.domain_name}-main"
  domain     = aws_codeartifact_domain.this.domain

  upstream {
    repository_name = aws_codeartifact_repository.npm_store.repository
  }

  tags = var.tags
}
