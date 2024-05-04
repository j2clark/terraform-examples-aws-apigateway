const { CognitoIdentityProviderClient, InitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { CognitoIdentityClient, GetIdCommand, GetCredentialsForIdentityCommand } = require("@aws-sdk/client-cognito-identity");

const config = {
    region: 'us-west-1',
    accountId: null,
    clientId: null,
    userpoolUrl: null,
    identityPoolId: null,
    username: 'example',
    password: 'example'
}

// const identityProviderClient = new CognitoIdentityProviderClient({region: config.region});

const args = process.argv.splice(2)
args.forEach((val) => {
    const key = val.split("=")[0]
    console.log()
    switch (key) {
        case 'ACCOUNT':
            config['accountId'] = val.split("=")[1];
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

if (!config['clientId']) {
    throw new Error('CLIENT_ID parameter required')
}

if (!config['identityPoolId']) {
    throw new Error('POOL_ID parameter required')
}

if (!config['userpoolUrl']) {
    throw new Error('POOL_URL parameter required')
}

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
    // console.log('idToken: ' + idToken);

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
        }).catch(err => {
            console.log('exception getting creds: ' + err);
        })

    }).catch(err => {
        console.log('Exception fetching identityId' + err);
    });
});
