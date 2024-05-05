# Domain Example

This example requires a domain available in AWS Route53

**_NOTE_** **_README_** The example requires a manual configuration in API Gateway - to Enable CORS on the endpoint. This is due to a bug in terraform when creating OPTIONS methods

**_Be sure to redeploy_** and wait about 1 minute for changes to propagate


### Route53 Domain Required

We will be creating ACM Certificates and A Records as part of this example


## Destroying Application

```shell
cd code/terraform
aws s3 cp s3://terraform-examples-aws-apigateway/terraform-examples-aws-apigateway-domain-main/init.tfvars init.tfvars
aws s3 cp s3://terraform-examples-aws-apigateway/terraform-examples-aws-apigateway-domain-main/application.tfvars application.tfvars
terraform init -backend-config="init.tfvars" 
terraform destroy -var-file="application.tfvars"
```