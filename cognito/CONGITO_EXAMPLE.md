# Cognito UserPool Example


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