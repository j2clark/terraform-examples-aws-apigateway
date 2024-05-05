# API Gateway Example: Simple Public Endpoint

This example creates a very basic API Gateway endpoint open to the world

<!--
TERRAFORM does not roll back on failures

## Destroying Application

```shell
    cd code/terraform
    aws s3 cp s3://terraform-examples-aws-apigateway/terraform-examples-aws-apigateway-public-main/init.tfvars init.tfvars
    aws s3 cp s3://terraform-examples-aws-apigateway/terraform-examples-aws-apigateway-public-main/application.tfvars application.tfvars
    terraform init -backend-config="init.tfvars" 
    terraform destroy -var-file="application.tfvars"
```
-->