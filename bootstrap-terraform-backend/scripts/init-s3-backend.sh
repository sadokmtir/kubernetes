#!/bin/bash
set -x 

# Generate backend config file dynamically
echo "Generating backend config..."
cat > backend.tf <<EOF
terraform {
  backend "s3" {}
}
EOF

#TODO: Update the config file values dynamically

# Generate backend config file dynamically
echo "Generating backend config..."
cat > backend.auto.tfbackend <<EOF
bucket          = "kube-9886" 
key            = "administrative/backend.tfstate"
region         = "us-east-1"
dynamodb_table = "kube-tfstatelock-9886"
profile      = "${AWS_PROFILE_ACCOUNT_ADMIN}"
EOF


# Initialize Terraform with the dynamically generated backend config
terraform init -backend-config=backend.auto.tfbackend
