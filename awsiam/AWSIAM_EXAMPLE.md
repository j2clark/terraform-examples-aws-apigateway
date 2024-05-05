# API Gateway Example: AWS_IAM Authentication

This example creates an API Gateway endpoint which uses AWS_IAM for access

The GET endpoint is https://${apiId}.execute-api.us-west-1.amazonaws.com/v1/hello

AWS_IAM is an authorization mechanism. The policies attached to the IAM role dictate what the requestor can access.

This is a complex setup, requiring a Cognito UserPool for authentication and a Cognito IdentityPool for authorization.

The step take to obtain credentials are explored in the node client

### Resource Name Prefix
All resource and service names start with the same name prefix: `${project_name}-${branch}`

`${project_name}` and `${branch}` are defined in [deploy/variables](deploy/variables.tf), and have defaults:
- **project_name** = `examples-apigateway-awsiam`
- **branch** = `main`

The _default_ name_prefix for this example is `examples-apigateway-awsiam-main`

## Deploy 

Initialize and Create Deploy resources
```shell
terraform init
terraform apply
```

#### Resources
S3 Bucket: Used for terraform backend state, and the location of files for [application cleanup](#application-cleanup)
IAM CodeBuild Role: Roles used to deploy application
IAM CodeBuild Policy: All IAM policies required to manage application resources
IAM Execution Role: Application (Lambda) Role  
CodeBuild Project w/GitHub Webhook: Project to deploy/update application

## Application 

Trigger a build using CodeBuild project created by Deploy

#### Resources
Lambda Function
API Gateway
IAM Authenticated Role
IAM Authenticated Policy
Cognito IdentityPool
Cognito UserPool
Cognito UserPool User (username: example, password: example)

## Client

#### Test the endpoint

API is the API Gateway ID. It is outputted in the CodeBuild console but also available in the API Gateway Console.

ACCOUNT is the AWS AccountId

CLIENT_ID is the Cognito UserPool _App Integration_ Client ID

POOL_ID is the IdentityPool ID

POOL_URL is the Cognito UserPool URL (First part of `Token signing key URL`, e.g https://cognito-idp.us-west-1.amazonaws.com/${UserPoolID})

From the [client directory](client), install npm dependencies and run:
```shell
npm install

node awsiam_client.js API="${apiId}" ACCOUNT="${accountId}" CLIENT_ID="${appIntegrationClientId}" POOL_ID="${identityPoolId}" POOL_URL="${userPoolUrl}" 
```

## Cleanup

#### Application Cleanup

Several artifacts are written to S3 as part of the application deployment.

Along with `application.tfstate`, an `init.tfvars` and `application.tfvars` file are written to S3 and can be used to `terraform init` and `plan/apply/destroy`

The S3 Bucket name pattern `${project_name}-${branch}-${accountid}` is the name prefix as described above, plus the AWS account id, e.g. `examples-apigateway-awsiam-main-0123456789`

From [application directory](application), download the tfvars files:
```shell
aws s3 cp s3://examples-apigateway-awsiam-main-0123456789/init.tfvars init.tfvars
aws s3 cp s3://examples-apigateway-awsiam-main-0123456789/application.tfvars application.tfvars
```

Initialize the local terraform state
```shell
terraform init -backend-config="init.tfvars"
```

Destroy the application
```shell
terraform destroy -var-file="application.tfvars"
```

#### Deploy Cleanup

```shell
terraform destroy -var-file="application.tfvars"
```

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