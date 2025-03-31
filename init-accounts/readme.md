# Kubernetes Cluster - Init Accounts

### !!! PS: This repo is supposed to be managed by users in the management account. !!!

You can create the accounts separately and then import them to Terraform or use Terraform to create them.

#### Import organization:
```bash
terraform import aws_organizations_organization.org ORGANIZATION_ID
```

#### Import dev account:
```bash
terraform import aws_organizations_account.dev_account DEV_ACCOUNT_ID
```

#### Import admin account:
```bash
terraform import aws_organizations_account.admin_account ADMIN_ACCOUNT_ID
```

### IAM Identity Center is Organization-Level

IAM Identity Center is a service that operates at the organization level. It must be enabled in the management account of your AWS Organization. Once enabled, it can be used to manage access across all accounts in the organization.

### Terraform Support

Terraform supports managing IAM Identity Center resources such as Permission Sets, Account Assignments, and SSO Instances. **However, the initial creation or enabling of IAM Identity Center itself cannot be done directly via Terraform. You must enable it manually through the AWS Management Console or AWS CLI**.

### Steps to Enable IAM Identity Center

#### Step 1: Enable IAM Identity Center Manually

Before using Terraform, you need to enable IAM Identity Center in the management account of your AWS Organization. Here's how:

**Using the AWS Management Console:**
1. Go to the IAM Identity Center console.
2. Click on Enable AWS SSO.
3. Follow the prompts to enable IAM Identity Center for your organization.

**Using the AWS CLI:**
Run the following command to enable IAM Identity Center:
```bash
aws sso-admin create-instance --instance-name "MyIdentityCenterInstance"
```

After enabling, you can retrieve the instance ARN using:
```bash
aws sso-admin list-instances
```

Using the AWS CLI :
You can use the create-group command to create a group via the AWS CLI:


#### Step 2: Create the IAM Identity Center group

```bash
aws sso-admin create-group \
    --instance-arn <SSO_INSTANCE_ARN> \
    --group-name "Admin team"
```


#### Step 3: Create a User and Add to Group

**Using AWS CLI:**
```bash
aws identitystore create-user \
    --identity-store-id <IDENTITY_STORE_ID> \
    --user-name "john.doe" \
    --emails "[{\"Value\":\"john.doe@example.com\",\"Type\":\"work\"}]" \
    --display-name "John Doe"
```

📌 Get the group ID:
```bash
aws identitystore list-groups --region <REGION> --identity-store-id  <IDENTITY_STORE_ID>
```

📌 Then, add the user to a group:
```bash
aws identitystore create-group-membership \
    --identity-store-id <IDENTITY_STORE_ID> \
    --group-id <GROUP_ID> \
    --member-id <USER_ID>
```
📌 Replace `<GROUP_ID>` and `<USER_ID>` with actual values from the created user and group.


#### Step 4: Create Permission Set with AdministratorAccess

aws sso-admin create-permission-set \
  --region <region>\
  --instance-arn <SSO_INSTANCE_ARN> \
  --name "AdminPermissionSet" \
  --description "Permission set with Administrator Access" \
  --session-duration "PT8H" \
  --managed-policies "arn:aws:iam::aws:policy/AdministratorAccess"

#### Step 5: Assign the Permission Set to the Group
aws sso-admin create-account-assignment \
  --region <region> \
  --instance-arn <SSO_INSTANCE_ARN>  \
  --permission-set-arn <PERMISSION_SET_ARN>\
  --principal-type GROUP \
  --principal-id <GROUP_ID> \
  --target-id <ADMIN_ACCOUNT_ID> \
  --target-type AWS_ACCOUNT


#### Step 6: Configure IAM Identity Center Using Terraform

Once IAM Identity Center is enabled, you can use Terraform to create the **administratives Permission set** in the dev and admin account.

#### Step 7: Configure IAM Identity Center Using Terraform
Run script `./scripts/iam.sh` to update the required trust policy in the dev account.






### EXPLANATION

* The provided `sso.tf` file will create **administratives Permission set** and assign it to the group crated above. This **administratives Permission set** will be used to manage the other 2 accounts: dev and admin account

