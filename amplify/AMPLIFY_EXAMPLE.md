

https://docs.amplify.aws/react/build-a-backend/auth/use-existing-cognito-resources/#use-auth-resources-without-an-amplify-backend


## Cleanup

#### Application Cleanup

Several artifacts are written to S3 as part of the application deployment.

Along with `application.tfstate`, an `init.tfvars` and `application.tfvars` file are written to S3 and can be used to `terraform init` and `plan/apply/destroy`

The S3 Bucket name pattern `${project_name}-${branch}-${accountid}` is the name prefix as described above, plus the AWS account id, e.g. `examples-apigateway-awsiam-main-0123456789`

From [application directory](application), download the tfvars files:
```shell
aws s3 cp s3://examples-apigateway-amplify-main-089600871681/init.tfvars init.tfvars
aws s3 cp s3://examples-apigateway-amplify-main-089600871681/application.tfvars application.tfvars
```

Initialize the local terraform state
```shell
terraform init -backend-config="init.tfvars"
```

Destroy the application
```shell
terraform destroy -var-file="application.tfvars"
```
