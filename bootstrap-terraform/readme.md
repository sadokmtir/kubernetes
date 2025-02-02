# Backend Terraform Setup

Follow these steps to set up the backend infrastructure using Terraform:

1. **Install Terraform**
    - Download and install Terraform from the [official website](https://www.terraform.io/downloads.html).

2. **Clone the Repository**
    - Clone this repository to your local machine:
      ```sh
      git clone https://github.com/yourusername/kubernetes-cluster.git
      cd kubernetes-cluster/backend-terraform
      ```

3. **Configure AWS Credentials**
    - Ensure your AWS credentials are configured. You can use the AWS CLI to configure them:
      ```sh
      aws configure sso --profile super-admin-profile
      export AWS_PROFILE=super-admin-profile 
      ```

4. **Initialize Terraform**
    - Initialize the Terraform working directory:
      ```sh
      terraform init
      ```

5. **Plan the Infrastructure**
    - Generate and review the execution plan:
      ```sh
      terraform plan out init.tfplan
      ```

6. **Apply the Configuration**
    - Apply the changes required to reach the desired state of the configuration:
      ```sh
      terraform apply init.tfplan
      ```

7. **Verify the Deployment**
    - Verify that the infrastructure has been deployed correctly by checking the AWS Management Console or using the AWS CLI.

8. **Destroy the Infrastructure (Optional)**
    - If you need to tear down the infrastructure, run:
      ```sh
      terraform plan -destroy -out=destroy.plan 
      terraform apply destroy.plan
      ```

9. **Move the local state to the newly created bucket**
    - Create the backend.tf config with new generated values for dynamodb and s3 bucket
    - run terraform init again:
      ```sh
      terraform init 
      ```
      
dynamodb_statelock = "kube-tfstatelock-9959"
state_bucket = "kube-9959"