# CORS Example

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