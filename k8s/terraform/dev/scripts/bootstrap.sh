#!/bin/bash
# set -x  # Enables debug mode 

trap 'echo "Error encountered at line $LINENO: $BASH_COMMAND"; return 1' ERR

cd "$(dirname "$0")/../../../../init-accounts"

DEV_ACCOUNT_ID=$(terraform output -raw dev_account_id)

cd "../k8s/terraform/dev"

# Create a temporary tfvars file
cat > account_ids.tfvars <<EOF
dev_account_id       = "$DEV_ACCOUNT_ID"
EOF
