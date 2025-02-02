# Define the Organization root
resource "aws_organizations_organization" "main" {
  feature_set = "ALL"
}

# Define Organizational Units
resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "infrastructure"
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_account" "dev_account" {
  name      = "DevAccount"
  email     = ""
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.infrastructure.id
}

resource "aws_organizations_account" "prod_account" {
  name      = "ProdAccount"
  email     = ""
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.infrastructure.id
}

resource "aws_organizations_account" "admin_account" {
  name      = "AdminAccount"
  email     = ""
  role_name = "OrganizationAccountAccessRole"
  parent_id = aws_organizations_organizational_unit.infrastructure.id
}
