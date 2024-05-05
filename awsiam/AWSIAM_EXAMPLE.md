# API Gateway Example: AWS_IAM Authentication

This example creates an API Gateway endpoint which uses AWS_IAM for access

## TODO: Documentation 

<!--
Todo: Use local identity pool to expose Authentication Role permissions 

TERRAFORM does not roll back on failures


```shell
    cd code/terraform
    aws s3 cp s3://terraform-examples-aws-apigateway/terraform-examples-aws-apigateway-awsiam_auth-main/init.tfvars init.tfvars
    aws s3 cp s3://terraform-examples-aws-apigateway/terraform-examples-aws-apigateway-awsiam_auth-main/application.tfvars application.tfvars
    terraform init -backend-config="init.tfvars" 
    terraform destroy -var-file="application.tfvars"
```
-->