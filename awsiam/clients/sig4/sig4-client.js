/*
usage: node ./sig4-client.js API_ID=racgz904ce USERPOOL_ID=us-west-1_UQmv4xJHM USERPOOL_WEB_CLIENT_ID=4aqm86e0kh41jmvr956lreicqt IDENTITYPOOL_ID=us-west-1:91027471-daeb-49ea-b2a0-8805e89eb201
 */

import { CognitoIdentityProviderClient, InitiateAuthCommand } from "@aws-sdk/client-cognito-identity-provider";
import { CognitoIdentityClient, GetIdCommand, GetCredentialsForIdentityCommand } from "@aws-sdk/client-cognito-identity";
import axios from "axios";

import { HttpRequest} from "@aws-sdk/protocol-http";
import { SignatureV4 } from "@aws-sdk/signature-v4";
import { Sha256 } from "@aws-crypto/sha256-browser";

/*const awsExports = {
    apiRegion: 'us-west-1',
    apiHost: 'racgz904ce',

    userPoolRegion: 'us-west-1',
    userPoolId: "us-west-1_UQmv4xJHM",
    userPoolWebClientId: "4aqm86e0kh41jmvr956lreicqt",

    identityPoolRegion: 'us-west-1',
    identityPoolId: "us-west-1:91027471-daeb-49ea-b2a0-8805e89eb201"
}*/

const awsExports = {
    apiRegion: 'us-west-1',
    apiHost: null,

    userPoolRegion: 'us-west-1',
    userPoolId: null,
    userPoolWebClientId: null,

    identityPoolRegion: 'us-west-1',
    identityPoolId: null
}

const args = process.argv.splice(2)
args.forEach((val) => {
    const key = val.split("=")[0]
    console.log()
    switch (key) {
        case 'API_REGION':
            awsExports['apiRegion'] = val.split("=")[1];
            break
        case 'API_ID':
            awsExports['apiId'] = val.split("=")[1];
            break
        case 'USERPOOL_REGION':
            awsExports['userPoolRegion'] = val.split("=")[1];
            break
        case 'USERPOOL_ID':
            awsExports['userPoolId'] = val.split("=")[1];
            break
        case 'USERPOOL_WEB_CLIENT_ID':
            awsExports['userPoolWebClientId'] = val.split("=")[1];
            break
        case 'IDENTITYPOOL_REGION':
            awsExports['identityPoolRegion'] = val.split("=")[1];
            break
        case 'IDENTITYPOOL_ID':
            awsExports['identityPoolId'] = val.split("=")[1];
            break
    }
});

if (!awsExports['apiId']) {
    throw new Error('API_ID parameter required')
}
if (!awsExports['userPoolId']) {
    throw new Error('USERPOOL_ID parameter required')
}
if (!awsExports['userPoolWebClientId']) {
    throw new Error('USERPOOL_WEB_CLIENT_ID parameter required')
}
if (!awsExports['identityPoolId']) {
    throw new Error('IDENTITYPOOL_ID parameter required')
}

const userPoolHost = 'cognito-idp.'+awsExports.userPoolRegion+'.amazonaws.com';
const cognitoUserPool = new CognitoIdentityProviderClient({region: awsExports.userPoolRegion});
const cognitoIdentityPool = new CognitoIdentityClient({region: awsExports.identityPoolRegion});


async function userPoolSignIn(username, password) {
    return await cognitoUserPool.send(new InitiateAuthCommand({
        ClientId: awsExports.userPoolWebClientId,
        AuthFlow: 'USER_PASSWORD_AUTH',
        AuthParameters: {
            USERNAME: username,
            PASSWORD: password,
        }
    })).then((authResponse) => {
        // console.log('auth: ' + auth)
        const idToken = authResponse['AuthenticationResult']['IdToken'];

        return idToken;
    });
}

async function getUserIdentityPoolId(idToken) {
    return await cognitoIdentityPool.send(new GetIdCommand({
        IdentityPoolId: awsExports.identityPoolId,
        Logins: getLoginParams(idToken)
    })).then((idResponse => {
        return idResponse.IdentityId;
    }))
}

async function getIdentityPoolCredentials(idToken, userIdentityPoolId) {
    return cognitoIdentityPool.send(new GetCredentialsForIdentityCommand({
        IdentityId: userIdentityPoolId,
        Logins: getLoginParams(idToken)
    })).then((credentialsResponse) => {
        return credentialsResponse['Credentials']
    })
}

function getLoginParams(idToken) {
    const userPoolUrl = userPoolHost + '/' + awsExports.userPoolId;
    return {
        // who logged us in? This is the app client url
        [userPoolUrl]: idToken
    };
}

const username = 'example'
const password = 'example'

userPoolSignIn(username, password).then(idToken => {
    getUserIdentityPoolId(idToken).then(userIdentityPoolId => {
        getIdentityPoolCredentials(idToken, userIdentityPoolId).then((credentials => {
            console.log('credentials: ' + JSON.stringify(credentials));

            const apiHost = awsExports.apiId+'.execute-api.'+awsExports.apiRegion+'.amazonaws.com'
            console.log('apiHost: ' + apiHost)
            const apiPath = '/v1/hello'
            const apiUrl =  'https://' + apiHost + apiPath
            console.log('apiUrl: ' + apiUrl)

            const signer = new SignatureV4({
                // credentials: defaultProvider(),
                credentials: {
                    accessKeyId: credentials.AccessKeyId,
                    secretAccessKey: credentials.SecretKey,
                    sessionToken: credentials.SessionToken
                },
                region: 'us-west-1',
                service: 'execute-api',
                sha256: Sha256
            });
            signer.sign(new HttpRequest({
                headers: {
                    'Content-Type': 'application/json',
                    'host': apiHost,
                    // 'apiKey':credentials.AccessKeyId,
                    // 'apiSecret': credentials.SecretKey
                },
                // hostname: apiHost,
                method: 'GET',
                path: apiPath
            })).then(signedRequest => {

                delete signedRequest.headers.host;
                console.log('SignatureV4 headers: ' + JSON.stringify(signedRequest.headers))

                axios.get(apiUrl, {
                    headers: signedRequest.headers
                }).then(response => {
                    console.log('SUCCESS! ' + JSON.stringify(response.data));
                }).catch(err => {
                    console.log('ERROR! ' + err);
                });
            })
        }));

    })
});