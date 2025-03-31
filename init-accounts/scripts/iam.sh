#!/bin/bash
# set -x  # Enables debug mode 

cd "$(dirname "$0")/.."

terraform init
terraform apply


export ADMIN_ACCOUNT_ID=$(terraform output -raw admin_account_id)
export MANAGEMENT_ACCOUNT_ID=$(terraform output -raw management_account_id)
DEV_ACCOUNT_ID=$(terraform output -raw dev_account_id)


# Use envsubst to replace placeholders in the policy.json file
envsubst < "$(dirname "$0")/policy.template.json" > "$(dirname "$0")/trust-policy.json" 

# Assume the role in the other account
ROLE_ARN="arn:aws:iam::$DEV_ACCOUNT_ID:role/OrganizationAccountAccessRole"
SESSION_NAME="AssumeRoleSession"
CREDENTIALS=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name $SESSION_NAME)

export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')


aws iam update-assume-role-policy --role-name OrganizationAccountAccessRole --policy-document file://$(dirname "$0")/trust-policy.json