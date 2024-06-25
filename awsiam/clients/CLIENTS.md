# AWSIAM Client Examples

## Amplify + aws4 signing

I personally prefer aws4 to sign requests, since it seems to be the cleanest approach

[Client uses Amplify gen 1, version 5](https://docs.amplify.aws/gen1/javascript/prev/build-a-backend/auth/enable-sign-up/)

We are only Amplify as a client; we are using our own Cognito UserPool and IdentityPool configurations.

[Amplify Docs](https://docs.amplify.aws/)

Some documents used to help me come to a solution:
* [How to secure Microservices on AWS with Cognito, API Gateway, and Lambda](https://www.freecodecamp.org/news/how-to-secure-microservices-on-aws-with-cognito-api-gateway-and-lambda-4bfaa7a6583c)
* [Configure AWS Amplify](https://sst.dev/chapters/configure-aws-amplify.html)
* [How to use IAM authorization for API gateway in AWS ?](https://medium.com/@shivkaundal/how-to-use-iam-authorization-for-api-gateway-in-aws-c35624e874d2)


## client-cognito-identity + aws4 signing

CognitoIdentityProviderClient is used to signIn

CognitoIdentityClient is used to get the AWS Credentials from the IdentityPool

aws4 is used to sign the http request
 

## client-cognito-identity + sig4 signing

CognitoIdentityProviderClient is used to signIn

CognitoIdentityClient is used to get the AWS Credentials from the IdentityPool

Signature4 is used to sign the http request