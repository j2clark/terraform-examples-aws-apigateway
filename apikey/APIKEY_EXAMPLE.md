# APIKEY Example

An api-gateway instance which requires an API Key to hit a `GET: /v1/hello endpoint`

## Dependencies/Expectations
* AWS CLI is installed and configured. Administrator rights are assumed
  ```shell
  aws --version
  ```
* Terraform is installed and in your PATH (
  ```shell
  terraform -version
  ```
* Git is installed and configured
  ```shell
  get version
  ```

Terraform does not roll back changes if overall process fails. Sometimes fixing the terraform issue and re-applying works, sometimes manually destroying all resources is required. A pain to be sure.

Naming of resources and services is consistent to make cleanup easier, and a list of resources created both in Deploy and Application are listed.

All names follow the pattern `${project_name}-apikey-${branch}-*`, e.g. `examples-apigateway-apikey-main-codebuild`

**_Note:_** AWS has restrictions of naming such as length and characters.

**_Note:_** AWS is inconsistent regarding uniqueness of names. You can have multiple roles with the same name, but not Lambdas.

## Standing up the example

Standing up the application is a 2 stage process.
1. Stand up a Codebuild project
2. Trigger a build

This is done specifically to highlight the application's required permissions.

I assume admin permissions from console, which means anything can be created.

Codebuild does not have admin permissions and must be tole explicitly what is required to deploy the application.

While sometimes tedious, this gives excellent insight into the precise policies required for the application.  

### Standing up Deploy

Standing up the Deploy environment is done from your local console.

From the deploy directory, `initialize`, `plan` and `apply` terraform.

There are 3 variables available to you:
* `repo`: The GitHub repo to pull code from
* `branch`: The GitHub branch where the code is to be pulled from. The default value is `main`.
* `project_name`: A simple yet concise name of this project. This will become part of the name of all resources and services

```shell
terraform init
```

```shell
#terraform plan -var "branch=main"
terraform plan 
```

```shell
#terraform apply -var "branch=main"
terraform apply
```

##### AWS Resources
- IAM Execution Role: `${project_name}-apikey-${branch}-execution`, e.g. `examples-apigateway-apikey-main-execution`
- IAM CodeBuild Role: `${project_name}-apikey-${branch}-codebuild`, e.g. `examples-apigateway-apikey-main-codebuild`
- IAM CodeBuild Policy: `${project_name}-apikey-${branch}-codebuild`, e.g. `examples-apigateway-apikey-main-codebuild`
- Codebuild: `${project_name}-apikey-${branch}`, e.g. `examples-apigateway-apikey-main`
- S3: `${project_name}-apikey-${branch}-${AWS.accountid}`, e.g. `examples-apigateway-apikey-main-0123456789`

##### CodeBuild buildspec.yml

The link between the Deploy environment variables and the application variables is found in the CodeBuild project and the buildsepc file.

In the resource `aws_codebuild_project.codebuild_backend` in [codebuild.tf](deploy/codebuild.tf) you will find several `environment.environment_variable` entries, e.g. `ARTIFACTS`

These are passed to the [buildspec.yml](deploy/buildspec.yml) as part of the build, which in turn uses these arguments to init and apply terraform:  
```text
- terraform apply -auto-approve -var "name_prefix=$NAME_PREFIX"
```

You will notice the application/variables.tf has a single required variable `name_prefix`

##### Variable Flow: 
Deploy Variables -> CodeBuild -> Buildspec -> Application Variables 

 
### Build the Application

**_NOTE:_** Never assume changes to API Gateway have automatically deployed. ALWAYS manually deploy after a build.  

The application is deployed by the CodeBuild application created in [Standing up Deploy](#standing-up-deploy)

Locate the CodeBuild project in the CodePipeline, and select Start Build

##### Application terraform outputs
In the codebuild logs, you should see the following outputs:
* api_gateway_id = "uqt0vu0h2k"
* apikey_name = "examples-apigateway-apikey-main-apikey"

You will need these to run the client

#### Debugging Codebuild permissions issues

NOTE: My experience has been any initial failures during the build process require a manual cleanup of resources. The backend state file has not been persisted so terraform assumes it is a fresh install

In the Codebuild console, you may see permissions errors which look something like this: 
```text
aws_lambda_function.lambda_get: Modifying... [id=examples-apigateway-apikey-main-hello]
╷
│ Error: updating Lambda Function (examples-apigateway-apikey-main-hello) code: operation error Lambda: UpdateFunctionCode, https response error StatusCode: 403, RequestID: 4dd425ef-d3a5-4e3a-af79-bbfbbe4feb44, api error AccessDeniedException: User: arn:aws:sts::089600871681:assumed-role/examples-apigateway-apikey-main-codebuild/AWSCodeBuild-f5cbe892-f114-4705-a1cd-9fcc6568a01e is not authorized to perform: lambda:UpdateFunctionCode on resource: arn:aws:lambda:us-west-1:089600871681:function:examples-apigateway-apikey-main-hello because no identity-based policy allows the lambda:UpdateFunctionCode action
│ 
│   with aws_lambda_function.lambda_get,
│   on lambda.tf line 7, in resource "aws_lambda_function" "lambda_get":
│    7: resource "aws_lambda_function" "lambda_get" {
│ 
╵
```

Lots of information in there, but the key is `User: arn:aws:sts::089600871681:assumed-role/examples-apigateway-apikey-main-codebuild/AWSCodeBuild-f5cbe892-f114-4705-a1cd-9fcc6568a01e is not authorized to perform: lambda:UpdateFunctionCode on resource: arn:aws:lambda:us-west-1:089600871681:function:examples-apigateway-apikey-main-hello`

Codebuild does not have appropriate Lambda permissions, in this case `lambda:UpdateFunctionCode`

Update `data.aws_iam_policy_document.codebuild_policy_document` in [codebuild_iam_policy.tf](deploy/codebuild_iam_policy.tf) by adding the permissions to the ManageLambdas statement
```terraform
statement {
    sid     = "ManageLambdas"
    effect  = "Allow"
    actions = [
      "lambda:GetFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:ListVersionsByFunction",
      "lambda:CreateFunction",
      "lambda:TagResource",
      "lambda:AddPermission",
      "lambda:GetPolicy",
      "lambda:UpdateFunctionCode",  # <== Add this
    ]
    resources = [
      "arn:aws:lambda:${local.region}:${local.account_id}:function:${local.name_prefix}*"
    ]
  }
```

Now apply changes to deploy
```shell
terraform apply
```

And Retry the build

Rinse, and repeat as necessary 

### Run the Client

Before you can run the client, you will need to locate the generated ApiKey, and copy its value.

```shell
npm install
```

```shell
node .\apikey_client.js API="uqt0vu0h2k" APIKEY="1aMhYJ2NG178LTW1DUeaS3Ks9wVi0DZ13pE0fcg6"
```



## Cleanup

### Application Cleanup

As part of Application deployment, the application state is written to S3
Additionally, 2 files are created to aid in cleanup: init.tf and application.tf.

Download these files to the application directory

The name of the S3 bucket follows the pattern `${project_name}-apikey-${branch}-${AWS.accountid}`, e.g. `examples-apigateway-apikey-main-0123456789`
```shell
aws s3 cp s3://examples-apigateway-apikey-main-0123456789/init.tfvars init.tfvars
aws s3 cp s3://examples-apigateway-apikey-main-0123456789/application.tfvars application.tfvars****
```

Initialize and destroy application
```shell
terraform init -backend-config="init.tfvars" 
terraform destroy -var-file="application.tfvars"
```

### Deploy Cleanup

The parameters passed must match the ones used to stand up

```shell
#terraform destroy -var "branch=main"
terraform destroy
```
