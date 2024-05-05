# API Gateway Example: Configuring CORS

This example demonstrates configuring CORS for a resource and 4XX/5XX responses

The GET endpoint is https://${apiId}.execute-api.us-west-1.amazonaws.com/v1/hello

**_WARNING!_** Creating OPTIONS methods using Terraform is broken.

My current approach is not to create OPTIONS methods using terraform, but after each update to manually enable CORS for resources and re-deploy. 

### Resource Name Prefix
All resource and service names start with the same name prefix: `${project_name}-${branch}`

`${project_name}` and `${branch}` are defined in [deploy/variables](deploy/variables.tf), and have defaults:
- **project_name** = `examples-apigateway-cors`
- **branch** = `main`

The _default_ name_prefix for this example is `examples-apigateway-cors-main`

## Deploy Resources

S3 Bucket: Used for terraform backend state, and the location of files for [application cleanup](#application-cleanup)
IAM CodeBuild Role: Roles used to deploy application
IAM CodeBuild Policy: All IAM policies required to manage application resources
IAM Execution Role: Application (Lambda) Role  
CodeBuild Project w/GitHub Webhook: Project to deploy/update application

## Application Resources

Lambda Function
API Gateway

## Test the endpoint with the Client

API is the API Gateway ID. It is outputted in the CodeBuild console but also available in the API Gateway Console.

From the [client directory](client), install npm dependencies and run:
```shell
npm install

node cors_client.js API="${apiId}"
```

## Application Cleanup

Several artifacts are written to S3 as part of the application deployment.

Along with `application.tfstate`, an `init.tfvars` and `application.tfvars` file are written to S3 and can be used to `terraform init` and `plan/apply/destroy`

The S3 Bucket name pattern `${project_name}-${branch}-${accountid}` is the name prefix as described above, plus the AWS account id, e.g. `examples-apigateway-cors-main-0123456789`

From [application directory](application), download the tfvars files:
```shell
aws s3 cp s3://examples-apigateway-cors-main-0123456789/init.tfvars init.tfvars
aws s3 cp s3://examples-apigateway-cors-main-0123456789/application.tfvars application.tfvars
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
CORS always trips me up, both coming and going.

Coming - while developing locally it always takes some time to realize where my errors are coming from, and then even more time on how to properly set up my dev environment.

Going - once everything works in dev environment, I push to prod only to discover it breaks for the same reason. 


Fundamentally, CORS is a Client Side Javascript issue. The server tells the client whether the client is allowed to use endpoint, but still it is the client that ultimately throws the error.

CORS does NOT prevent someone from calling the endpoint. Authorization is required to do that.

## Development vs Production
For VueJS, I take several steps to ste things up to work in both development AND production:

1. Set up a proxy to spoof the endpoint:

    vue.config.js 
    ```javascript
    const { defineConfig } = require('@vue/cli-service')
    module.exports = defineConfig({
        transpileDependencies: true,
        devServer: {
            proxy: 'https://api.j2clark.info'
        }
    })
    ```

    so what is going on here?

    In .vue.development, we are using http://localhost:8082 (assuming we run on port 8082 locally, and we want to use localhost instead of IP)
    
    The proxy knows we are serving http://localhost:8082 and replaces it with the value of devServer.proxy
    
    This fools the browser into thinking we have satisfied CORS? This part I am not clear on.

2. Use env parameters to control which endpoint to use for each environment 

    create 2 files, .env.development and .env.production:
    
    .env.production
    ```text
    VUE_APP_API_URL=https://api.j2clark.info
    ```
    
    .env.development
    ```text
    VUE_APP_API_URL=http://localhost:8082
    ```

3. Use environment variables to dynamically generate the url:

    ```javascript
    import axios from 'axios';
    
    this.greeting = ''
    this.error = ''
    
    const url = process.env.VUE_APP_API_URL
    console.profile('url: ' + url)
    // console.log('FETCH...')
    axios.get(url + '/hello', {
        headers: {
            "Content-type": "application/json",
        }
    }).then(response => {
        this.greeting = response.data.body
    }).catch(err => {
        this.error = err.message;
    });
    ```

## Destroying Application

```shell
cd code/terraform
aws s3 cp s3://terraform-examples-aws-apigateway/terraform-examples-aws-apigateway-cors-main/init.tfvars init.tfvars
aws s3 cp s3://terraform-examples-aws-apigateway/terraform-examples-aws-apigateway-cors-main/application.tfvars application.tfvars
terraform init -backend-config="init.tfvars" 
terraform destroy -var-file="application.tfvars"
```
-->