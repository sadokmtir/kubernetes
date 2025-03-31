
# Backend Terraform


## steps to follow to set this project up for the first time

### Prerequisites:
- You need to have admin access to your management account. You can do that using the `aws configure sso` command

### Steps to follow:
1. Follow the instructions from the "init-accounts" repo to set-up the accounts and the IAM identity center. 

2. Run the script `bootstrap.sh` from the "bootstrap-terraform-backend" repo using this command `cd bootstrap-terraform-backend && source ./scripts/bootstrap.sh`. This will set-up the necessary bash and terraform variables needed for terraform in the repo "bootstrap-terraform-backend". The script will output a tfplan.

3. Check and apply the plan using this command: `terraform apply tfplan`. At this stage the terraform backend is still locally but we want to save to the admin accound and use AWS S3 and Dynamodb that we just crteated as backend.

4. Get the generated `state_bucket` and `dynamodb_statelock`output values and replace them with the corresponding values in the `init-s3-backend.sh`

5. Ru the script `./scripts/bootstrap.sh` in order to migrate the local state to the previously created S3 backend.

6. From now on you 
    * could use the `export AWS_PROFILE=management-acount-profile` and `terraform plan` to manage terraform resources in the "init-accounts" repo
    
    * and use `export AWS_PROFILE=admin-acount-profile` and `terraform plan -var-file=account-ids.tfvars -out=tfplan` to manage resources in the "bootstrap-terraform-backend" repo. 


### NOTES:

The aws config file `config.example` shows the different profiles used to deploy to different account.
  - **management-acount-profile** is used to deploy to the management account.
  - **admin-account-profile** is used to deploy to the admin account, which is used to create the terraform backend using the repo "bootstrap-terraform-backend"

