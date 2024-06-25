import { Amplify, Auth } from 'aws-amplify';
import axios from "axios";
import aws4 from "aws4";

const awsExports = {
    apiRegion: 'us-west-1',
    apiHost: 'racgz904ce',

    userPoolRegion: 'us-west-1',
    userPoolId: "us-west-1_UQmv4xJHM",
    userPoolWebClientId: "4aqm86e0kh41jmvr956lreicqt",

    identityPoolRegion: 'us-west-1',
    identityPoolId: "us-west-1:91027471-daeb-49ea-b2a0-8805e89eb201"
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

        const apiHost = awsExports.apiHost+'.execute-api.'+awsExports.apiRegion+'.amazonaws.com'
        console.log('apiHost: ' + apiHost)
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
