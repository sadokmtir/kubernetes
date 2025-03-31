# Define the Organization root
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
  ]
  aws_service_access_principals = [
    "sso.amazonaws.com",
  ]
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "infrastructure"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_account" "admin_account" {
  name      = "AdminAccount"
  email     = var.admin_account_email
  parent_id = aws_organizations_organizational_unit.infrastructure.id
}

resource "aws_organizations_account" "dev_account" {
  name      = "DevAccount"
  email     = var.dev_account_email
  parent_id = aws_organizations_organizational_unit.infrastructure.id
}

output "admin_account_id" {
  value = aws_organizations_account.admin_account.id
}
output "dev_account_id" {
  value = aws_organizations_account.dev_account.id
}

data "aws_caller_identity" "current" {}

# Output the Management Account ID
output "management_account_id" {
  value = data.aws_caller_identity.current.account_id
}
