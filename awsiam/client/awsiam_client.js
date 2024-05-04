const { HttpRequest} = require("@aws-sdk/protocol-http");
const { defaultProvider } = require("@aws-sdk/credential-provider-node");
const { SignatureV4 } = require("@aws-sdk/signature-v4");
const { Sha256 } = require("@aws-crypto/sha256-browser");
const { CognitoIdentityProviderClient, InitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { CognitoIdentityClient, GetIdCommand, GetCredentialsForIdentityCommand } = require("@aws-sdk/client-cognito-identity");
// const  { fromCognitoIdentity, fromCognitoIdentityPool } = require("@aws-sdk/credential-providers"); // ES6 import
const axios = require("axios");

const config = {
    region: 'us-west-1',
    accountId: null,
    apiId: null,
    clientId: null,
    userpoolUrl: null,
    identityPoolId: null,
    endpoint: '/v1/hello',
    username: 'example',
    password: 'example'
}

const args = process.argv.splice(2)
args.forEach((val) => {
    const key = val.split("=")[0]
    console.log()
    switch (key) {
        case 'ACCOUNT':
            config['accountId'] = val.split("=")[1];
            break
        case 'API':
            config['apiId'] = val.split("=")[1];
            break
        case 'CLIENT_ID':
            config['clientId'] = val.split("=")[1];
            break
        case 'POOL_ID':
            config['identityPoolId'] = val.split("=")[1];
            break
        case 'POOL_URL':
            config['userpoolUrl'] = val.split("=")[1];
            break
    }
});

if (!config['accountId']) {
    throw new Error('ACCOUNT parameter required')
}

if (!config['apiId']) {
    throw new Error('API parameter required')
}

if (!config['clientId']) {
    throw new Error('CLIENT_ID parameter required')
}

if (!config['identityPoolId']) {
    throw new Error('POOL_ID parameter required')
}

if (!config['userpoolUrl']) {
    throw new Error('POOL_URL parameter required')
}


const host = config.apiId + '.execute-api.' + config.region + '.amazonaws.com'
const url = 'https://' + host + config.endpoint

const identityProviderClient = new CognitoIdentityProviderClient({region: config.region});
identityProviderClient.send(new InitiateAuthCommand({
    ClientId: config.clientId,
    AuthFlow: 'USER_PASSWORD_AUTH',
    AuthParameters: {
        USERNAME: config.username,
        PASSWORD: config.password,
    }
})).then((authResponse) => {
    // https://mahmutcanga.com/2021/10/26/connecting-postman-to-amazon-cognito-user-pools-for-api-access-tokens/
    const idToken = authResponse['AuthenticationResult']['IdToken'];
    const identityClient = new CognitoIdentityClient({region: config.region});
    identityClient.send(new GetIdCommand({
        IdentityPoolId: config.identityPoolId,
        AccountId: config.accountId,
        Logins: {
            // who logged us in? This is the app client url
            [config.userpoolUrl]: idToken
        }
    })).then((idResponse) => {
        const identityId = idResponse.IdentityId;
        // console.log('identityId: ' + identityId);

        identityClient.send(new GetCredentialsForIdentityCommand({
            IdentityId: identityId,
            Logins: {
                [config.userpoolUrl]: idToken
            }
        })).then((credsResponse) => {
            const creds = credsResponse['Credentials']
            console.log('creds: ' + JSON.stringify(creds));

            // TODO: figure out how to use credential-providers here, so simplify
            // const signer = new SignatureV4({
            //     credentials: fromCognitoIdentityPool({
            //         identityPoolId: config.identityPoolId,
            //         accountId: config.accountId,
            //         logins: {
            //             [config.userpoolUrl]: idToken
            //         },
            //         clientConfig: { region: config.region }
            //     }),
            //     region: 'us-west-1',
            //     service: 'execute-api',
            //     sha256: Sha256
            // });

            const signer = new SignatureV4({
                credentials: defaultProvider(),
                region: 'us-west-1',
                service: 'execute-api',
                sha256: Sha256
            });
            signer.sign(new HttpRequest({
                headers: {
                    'Content-Type': 'application/json',
                    'host': host,
                    'apiKey':creds.AccessKeyId,
                    'apiSecret': creds.SecretKey
                },
                hostname: host,
                method: 'GET',
                path: config.endpoint
            })).then(signedRequest => {
                // console.log(JSON.stringify(signedRequest))
                axios.get(url, {
                    headers: signedRequest.headers
                }).then(response => {
                    console.log('SUCCESS! ' + JSON.stringify(response.data));
                }).catch(err => {
                    console.log('ERROR! ' + err);
                });
            }).catch(err => {
                console.log(err)
            });
        }).catch(err => {
            console.log('exception getting creds: ' + err);
        })
    }).catch(err => {
        console.log('Exception fetching identityId' + err);
    });
});


