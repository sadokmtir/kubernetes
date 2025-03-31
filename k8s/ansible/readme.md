
1- Install the kubespray submodule: `git submodule update --init`

2- Make sure you run terraform first: 
```
cd ../terraform/dev
terraform plan -var-file=account_ids.tfvars -out=tfplan
terraform apply tfplan
``` 

3- Run script to deploy kubernetes using kubespray `./scripts/bootstrap.sh`