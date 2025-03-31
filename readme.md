
# Backend Terraform

## Motivation behind this project:
The motivation behind this project is to provide a blue-print for deploying self-managed kubernetes on AWS using Infrastrutre as code and bash-scripts to automate the process as much as possible. 

**It is WIP that could be used as ground set-up for deploying kuberentes from scratch on AWS**. 

## Project Structure:

- `bootstrap-terraform-backend/` : The repository that would provision the required components for using s3 as backend.
- `init-accounts/`: The repository that contains our organization structure and the different account to be used.
- `k8s/`: The repository that is used to provision the infrastructure in each environment and deploy the kubernetes cluster there.

> PS: Each repo mentioned above has its own readme for more detailed step by step configuration.

## Steps to follow to set-up this project for the first time

### 1. Prerequisites:
- You need to have admin access to your management account. You can do that using the `aws configure sso` command



### 2. Steps to follow:
1. Follow the instructions from the "init-accounts" repo to set-up the accounts and the IAM identity center. 

2. Run the script `bootstrap.sh` from the "bootstrap-terraform-backend" repo using this command `cd bootstrap-terraform-backend && source ./scripts/bootstrap.sh`. This will set-up the necessary bash and terraform variables needed for terraform in the repo "bootstrap-terraform-backend". The script will output a tfplan.

3. Check and apply the plan using this command: `terraform apply tfplan`. At this stage the terraform backend is still locally but we want to save to the admin accound and use AWS S3 and Dynamodb that we just crteated as backend.

4. Get the generated `state_bucket` and `dynamodb_statelock`output values and replace them with the corresponding values in the `init-s3-backend.sh`

5. Run the script `./scripts/init-s3-backend-sh` in order to migrate the local state to the previously created S3 backend.

6. From now on  
    * you could use the `export AWS_PROFILE=management-acount-profile` and `terraform plan` to manage terraform resources in the "init-accounts" repo
    
    * and use `export AWS_PROFILE=admin-acount-profile` and `terraform plan -var-file=account-ids.tfvars -out=tfplan` to manage resources in the "bootstrap-terraform-backend" repo. 

7. After all ground components are set-up. We could move to the `k8s/` where the actual provisioning and deployment of our kuberenetes takes place.


### NOTES:

The aws config file `awsconfig.example` shows the different profiles used to deploy to different accounts.
  - **management-acount-profile** is used to deploy to the management account.
  - **admin-account-profile** should be used by the administrators to manage the other accounts. 
    * It is used to deploy to the **admin account**, which is used to create the terraform backend using the repo <u>"bootstrap-terraform-backend"</u> 
    and 
    * to deploy to the **dev account** by assuming the admin role in it.

