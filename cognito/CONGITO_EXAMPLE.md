# API Gateway Example: Cognito Authentication

This example creates an API Gateway endpoint which uses Cognito for authentication

Cognito authenticated methods are open to anyone authenticated by the user pool

The GET endpoint is https://${apiId}.execute-api.us-west-1.amazonaws.com/v1/hello

### Resource Name Prefix
All resource and service names start with the same name prefix: `${project_name}-${branch}`

`${project_name}` and `${branch}` are defined in [deploy/variables](deploy/variables.tf), and have defaults:
- **project_name** = `examples-apigateway-cognito`
- **branch** = `main`

The _default_ name_prefix for this example is `examples-apigateway-cognito-main`

## Deploy 

Initialize and Create Deploy resources
```shell
terraform init
terraform apply
```

#### Resources
* S3 Bucket: Used for terraform backend state, and the location of files for [application cleanup](#application-cleanup)
* IAM CodeBuild Role: Roles used to deploy application
* IAM CodeBuild Policy: All IAM policies required to manage application resources
* IAM Execution Role: Application (Lambda) Role  
* CodeBuild Project w/GitHub Webhook: Project to deploy/update application

## Application 

Trigger a build using CodeBuild project created by Deploy

#### Resources

* Lambda Function
* API Gateway
* API Gateway Authorizer
* Cognito UserPool
* Cognito UserPool User (username: example, password: example)

## Client

#### Test the endpoint

API is the API Gateway ID. It is outputted in the CodeBuild console but also available in the API Gateway Console.

ACCOUNT is the AWS AccountId

CLIENT_ID is the Cognito UserPool _App Integration_ Client ID

From the [client directory](client), install npm dependencies and run:
```shell
npm install

node cognito_client.js API="${apiId}" ACCOUNT="${accountId}" CLIENT_ID="${appIntegrationClientId}"
```

## Cleanup

#### Application Cleanup

Several artifacts are written to S3 as part of the application deployment.

Along with `application.tfstate`, an `init.tfvars` and `application.tfvars` file are written to S3 and can be used to `terraform init` and `plan/apply/destroy`

The S3 Bucket name pattern `${project_name}-${branch}-${accountid}` is the name prefix as described above, plus the AWS account id, e.g. `examples-apigateway-cognito-main-0123456789`

From [application directory](application), download the tfvars files:
```shell
aws s3 cp s3://examples-apigateway-cognito-main-0123456789/init.tfvars init.tfvars
aws s3 cp s3://examples-apigateway-cognito-main-0123456789/application.tfvars application.tfvars
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
```shell
    cd code/terraform
    aws s3 cp s3://terraform-examples-aws-apigateway/terraform-examples-aws-apigateway-cognito-main/init.tfvars init.tfvars
    aws s3 cp s3://terraform-examples-aws-apigateway/terraform-examples-aws-apigateway-cognito-main/application.tfvars application.tfvars
    terraform init -backend-config="init.tfvars" 
    terraform destroy -var-file="application.tfvars"
```


```shell
curl -X GET  https://dtugrb3ww2.execute-api.us-west-1.amazonaws.com/v1/hello  -H 'Content-Type: application/json' && echo ""
```
```json
{"message":"Unauthorized"}
```

https://docs.aws.amazon.com/cognito/latest/developerguide/token-endpoint.html

```shell
#base64(client_id:client_secret)
#base64(example:example) => 'ZXhhbXBsZTpleGFtcGxl'
#curl -X POST  'https://auth.demo.yegorius.com/oauth2/token?grant_type=client_credentials'  -H 'Authorization: Basic base64(client_id:client_secret)'  -H 'Content-Type: application/x-www-form-urlencoded'   && echo ""
curl -X POST -H "Authorization: Basic ZXhhbXBsZTpleGFtcGxl" -H "Content-Type: application/x-www-form-urlencoded" "https://terraform-examples.auth.us-west-1.amazoncognito.com/oauth2/token?grant_type=client_credentials"  
curl -X POST -H "Authorization: Basic base64(example:example)" -H "Content-Type: application/x-www-form-urlencoded" "https://terraform-examples.auth.us-west-1.amazoncognito.com/oauth2/token?grant_type=client_credentials"


curl -X POST "https://terraform-examples.auth.us-west-1.amazoncognito.com/oauth2/token?grant_type=client_credentials" -H "Authorization: Basic ZXhhbXBsZTpleGFtcGxl"
```
-->