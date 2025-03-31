# Data source to get the SSO instance ARN
data "aws_ssoadmin_instances" "sso_instance" {}


resource "aws_ssoadmin_permission_set" "administrative_permission_set" {
  name             = "AdministrativePermissionSet"
  instance_arn     = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  description      = "Admin access toye AWS services"
  session_duration = "PT3H"
  relay_state      = "https://console.aws.amazon.com"
}


// Attach the managed IAM policy to the permission set
resource "aws_ssoadmin_managed_policy_attachment" "administrative_policy_attachment" {
  instance_arn       = data.aws_ssoadmin_instances.sso_instance.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.administrative_permission_set.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


// Use the created permission set for th admin account
resource "aws_ssoadmin_account_assignment" "admin_account_assignment" {
  instance_arn       = data.aws_ssoadmin_instances.sso_instance.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.administrative_permission_set.arn
  principal_type     = "GROUP"
  principal_id       = var.admin_team_group_id
  target_id          = aws_organizations_account.admin_account.id
  target_type        = "AWS_ACCOUNT"
}

// Use the created permission set for th dev account
resource "aws_ssoadmin_account_assignment" "dev_account_assignment" {
  instance_arn       = data.aws_ssoadmin_instances.sso_instance.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.administrative_permission_set.arn
  principal_type     = "GROUP"
  principal_id       = var.admin_team_group_id
  target_id          = aws_organizations_account.dev_account.id
  target_type        = "AWS_ACCOUNT"
}
