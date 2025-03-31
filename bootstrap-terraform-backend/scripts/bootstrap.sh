#!/bin/bash
# set -x  # Enables debug mode 

trap 'echo "Error encountered at line $LINENO: $BASH_COMMAND"; return 1' ERR


cd "$(dirname "$0")/../../init-accounts"
terraform init
# terraform plan
terraform apply



export ADMIN_ACCOUNT_ID=$(terraform output -raw admin_account_id)
DEV_ACCOUNT_ID=$(terraform output -raw dev_account_id)
MANAGEMENT_ACCOUNT_ID=$(terraform output -raw management_account_id)

# Generate aws profile which assume the role in admin account
export AWS_PROFILE_ACCOUNT_ADMIN=admin-account-profile

#TODO: Update the config file values dynamically "sso_role_name"
echo "Generating AWS Profile..."
cat >> ~/.aws/config  <<EOF
[profile ${AWS_PROFILE_ACCOUNT_ADMIN}]
sso_session = my-sso
sso_account_id = ${ADMIN_ACCOUNT_ID}
sso_role_name = AdministrativePermissionSet
region = us-east-1
output = json
EOF

cd "../bootstrap-terraform"

# Create a temporary tfvars file
cat > account_ids.tfvars <<EOF
admin_account_id     = "$ADMIN_ACCOUNT_ID"
dev_account_id       = "$DEV_ACCOUNT_ID"
management_account_id = "$MANAGEMENT_ACCOUNT_ID"
EOF


terraform init
terraform plan -var-file=account_ids.tfvars -out=tfplan

# terraform apply tfplan

echo "Terraform execution completed!"


