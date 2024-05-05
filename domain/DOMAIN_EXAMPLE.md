# API Gateway Example: Custom Domain Names

This example maps an API Gateway deployment stage to a custom domain name.

**_WARNING!_** Requires a domain available in AWS Route53

The GET endpoint is `https://api.${domain}/hello`

### Resource Name Prefix
All resource and service names start with the same name prefix: `${project_name}-${branch}`

`${project_name}` and `${branch}` are defined in [deploy/variables](deploy/variables.tf), and have defaults:
- **project_name** = `examples-apigateway-domain`
- **branch** = `main`

The _default_ name_prefix for this example is `examples-apigateway-domain-main`

## Deploy Resources

S3 Bucket: Used for terraform backend state, and the location of files for [application cleanup](#application-cleanup)
IAM CodeBuild Role: Roles used to deploy application
IAM CodeBuild Policy: All IAM policies required to manage application resources
IAM Execution Role: Application (Lambda) Role  
CodeBuild Project w/GitHub Webhook: Project to deploy/update application

## Application Resources

Lambda Function
API Gateway
API Gateway Custom Domain
ACM Certificate
Route53 A Records

## Test the endpoint with the Client

From the [client directory](client), install npm dependencies and run:
```shell
npm install

node domain_client.js DOMAIN="${domain}"
```

## Application Cleanup

Several artifacts are written to S3 as part of the application deployment.

Along with `application.tfstate`, an `init.tfvars` and `application.tfvars` file are written to S3 and can be used to `terraform init` and `plan/apply/destroy`

The S3 Bucket name pattern `${project_name}-${branch}-${accountid}` is the name prefix as described above, plus the AWS account id, e.g. `examples-apigateway-domain-main-0123456789`

From [application directory](application), download the tfvars files:
```shell
aws s3 cp s3://examples-apigateway-domain-main-0123456789/init.tfvars init.tfvars
aws s3 cp s3://examples-apigateway-domain-main-0123456789/application.tfvars application.tfvars
```

Initialize the local terraform state
```shell
terraform init -backend-config="init.tfvars"
```

Destroy the application
```shell
terraform destroy -var-file="application.tfvars"
```


<!--
**_NOTE_** The example requires a manual configuration in API Gateway - to Enable CORS on the endpoint. This is due to a bug in terraform when creating OPTIONS methods

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
-->