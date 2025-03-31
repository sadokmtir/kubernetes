# Kubernetes Cluster with Terraform

This project sets up a Kubernetes cluster using Terraform.

## Configuration


- Run the script `bootstrap.sh` to get the required account ids
```
cd ENVIRONMENT
./scripts/bootstap.sh

```
- Login with the admin profile and export the profile
 ```aws sso login --profile admin-account-profile
 export AWS_PROFILE=admin-account-profile
 ```

- Init the backend for the specific environmen by:
```
 terraform init
```

- Run plan: `terraform plan -var-file=account_ids.tfvars -out=tfplan` 


