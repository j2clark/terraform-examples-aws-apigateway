# Terraform Examples: AWS: API Gateway

Fully functional examples which demonstrate terraform configurations, describe IAM Policy requirements, and demonstrate access using node client.

## Each example contains 3 parts

Each application is designed to be a stand-alone application, namespaced such that all examples can be deployed simultaneously, as well as several version of a single example.  

Each example consists of the following, to be exercised in order:
- [deploy](#deploy) 
- [application](#application) 
- [client](#client)

Instructions on cleaning up are described in each example.

### deploy

Deploy is used to create a CodeBuild project and all infrastructure requirements for the application.

I use a CodeBuild project to ensure we expose all IAM Policy requirements for deploying an application. 

Deploying service and resources from the command line often uses an administrator role, with god permissions, which hides the policy requirements for an application.    

### application

The application is deployed using CodeBuild.

Destroying the application is a manual process, but I have tried to make this as easy as downloading a couple of files from S3 and running some short terraform commands

### client

The clients are node scripts which highlight how to access the api-gateway endpoint.

These clients rely on @aws-sdk V3 where applicable, and show how to pass appropriate credentials. 

## The Examples

* [Public](public/PUBLIC_EXAMPLE.md)
* [API Key](apikey/APIKEY_EXAMPLE.md)
* [CORS](cors/CORS_EXAMPLE.md)
* [Cognito](cognito/CONGITO_EXAMPLE.md)
* [AWS_IAM](awsiam/AWSIAM_EXAMPLE.md)
* [Domain](domain/DOMAIN_EXAMPLE.md)
