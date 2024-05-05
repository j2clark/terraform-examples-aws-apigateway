const axios = require("axios");
const { CognitoIdentityProviderClient, InitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");
// const { CognitoIdentityClient, GetIdCommand } = require("@aws-sdk/client-cognito-identity");

const config = {
    region: 'us-west-1',
    accountId: null,
    apiId: null,
    endpoint: '/v1/hello',
    clientId: null,
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
    console.log('idToken: ' + idToken);

    axios.get(url, {
        headers: {
            "Content-type": "application/json",
            'Authorization': idToken
        }
    }).then(response => {
        console.log('SUCCESS! ' + JSON.stringify(response.data));
    }).catch(err => {
        console.log('ERROR! ' + err);
    });
}).catch(err => {
    console.log('Exception logging in' + err);
});

