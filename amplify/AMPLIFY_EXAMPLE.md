https://medium.com/@shivkaundal/how-to-use-iam-authorization-for-api-gateway-in-aws-c35624e874d2#id_token=eyJhbGciOiJSUzI1NiIsImtpZCI6IjNkNTgwZjBhZjdhY2U2OThhMGNlZTdmMjMwYmNhNTk0ZGM2ZGJiNTUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIyMTYyOTYwMzU4MzQtazFrNnFlMDYwczJ0cDJhMmphbTRsamRjbXMwMHN0dGcuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIyMTYyOTYwMzU4MzQtazFrNnFlMDYwczJ0cDJhMmphbTRsamRjbXMwMHN0dGcuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTY5NjM0NTA1MzA3MDE1NTg2NDkiLCJlbWFpbCI6ImoyY2xhcmtAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5iZiI6MTcxOTMzMTA0MiwibmFtZSI6IkphbWllIENsYXJrIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FDZzhvY0p3N3FSWEFXeHFqN2hHVEY0eXVHRThvREdlUE1RUWduOHk2WnFHM1p4cVFyd2tDYkZsY0E9czk2LWMiLCJnaXZlbl9uYW1lIjoiSmFtaWUiLCJmYW1pbHlfbmFtZSI6IkNsYXJrIiwiaWF0IjoxNzE5MzMxMzQyLCJleHAiOjE3MTkzMzQ5NDIsImp0aSI6ImI2ZmIyODliYjViY2Q2OWYyOTVkMWEwOWRlMzQ2NmM0NWNlYzNmMGQifQ.AtTUq6Kruqxcm7h475XvZ5qzqCUwJxistXqCOhsiIhYWi1i1-pLE8dqzpuOGIyjt94ezrkmVUc_lV2eeqY0VzcPTbgOR_mY5PrJxD6uvyc14jcQhSiMEzlSKTeBbwRqLMdwIuWh2X68srhoMGX9XkWUsXm__Fbe-7_6lORaum0T1rHpD_NSKhBau2PxfWjLfvSxOqVKp_f4lpVX6zyo5tuuYGyhI4OFXgM2IXxBdNMJ8r9VcdtlLvI0fki41jLHbDho041xSSWH84aKeaho3mzvgDg3TKqllL1kYvnw6xVMEe-5c6lN9Phu1FE-__3Eq6N8vF8Gw-9f-MqumFj5QPQ

https://docs.amplify.aws/react/build-a-backend/auth/use-existing-cognito-resources/#use-auth-resources-without-an-amplify-backend

https://docs.amplify.aws/

[Amplify: gen1, v5](https://docs.amplify.aws/gen1/javascript/prev/build-a-backend/auth/set-up-auth/)

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
