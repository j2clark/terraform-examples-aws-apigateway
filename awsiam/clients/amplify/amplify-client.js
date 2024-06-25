/*
usage: node ./amplify-client.js API_ID=5tlc9lgnxk USERPOOL_ID=us-west-1_13hh7PE0O USERPOOL_WEB_CLIENT_ID=p4fb33a4rhpj5kjp708pkup6h IDENTITYPOOL_ID=us-west-1:39693ee6-a0ee-4d0d-9041-0866003d66b5
 */

import { Amplify, Auth } from 'aws-amplify';
import axios from "axios";
import aws4 from "aws4";

const awsExports = {
    apiRegion: 'us-west-1',
    apiId: null,

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

// https://docs.amplify.aws/gen1/javascript/prev/build-a-backend/auth/set-up-auth/
Amplify.configure({
    Auth: {
            region: awsExports.userPoolRegion,
            userPoolId: awsExports.userPoolId,
            userPoolWebClientId: awsExports.userPoolWebClientId,

            identityPoolRegion: awsExports.identityPoolRegion,
            identityPoolId: awsExports.identityPoolId,

            // OPTIONAL - Enforce user authentication prior to accessing AWS resources or not
            mandatorySignIn: false,

            // OPTIONAL - Manually set the authentication flow type. Default is 'USER_SRP_AUTH'
            authenticationFlowType: 'USER_PASSWORD_AUTH',
    }
});

const currentConfig = Auth.configure();
console.log('currentConfig: ' + JSON.stringify(currentConfig));

const username = 'example'
const password = 'example'

async function signIn(username, password) {
    try {
        const user = await Auth.signIn(username, password);
        console.log('user: ' + JSON.stringify(user))
    } catch (error) {
        console.log('error signing in', error);
    }
}

async function getCurrentCredentials() {
    const credentials = await Auth.currentCredentials();
    console.log('credentials: ' + JSON.stringify(credentials))
    return credentials
}

signIn(username, password).then(() => {
    console.log('signed in')

    getCurrentCredentials().then((credentials) => {
        console.log('credentials: ' + JSON.stringify(credentials))

        const apiHost = awsExports.apiId+'.execute-api.'+awsExports.apiRegion+'.amazonaws.com'
        // console.log('apiHost: ' + apiHost)
        const apiPath = '/v1/hello'
        const apiUrl =  'https://' + apiHost + apiPath
        console.log('apiUrl: ' + apiUrl)

        const opts = {
            method: "GET",
            service: "execute-api",
            // region: awsExports.apiRegion,
            path: apiPath,
            host: apiHost,
            headers: {
                'Content-Type': 'application/json'
                // "x-api-key": apiKey
            },
            // url: apiUrl
        };

        const signedRequest = aws4.sign(opts, {
            accessKeyId: credentials.accessKeyId,
            secretAccessKey: credentials.secretAccessKey,
            sessionToken: credentials.sessionToken
        });

        delete signedRequest.headers.Host;

        console.log('aws4 headers: ' + JSON.stringify(signedRequest.headers))
        axios.get(apiUrl, {
            headers: signedRequest.headers
        }).then(response => {
            console.log('SUCCESS! ' + JSON.stringify(response.data));
        }).catch(err => {
            console.log('ERROR! ' + err);
        });
    })
})
