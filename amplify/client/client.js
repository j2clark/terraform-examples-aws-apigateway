import { CognitoIdentityProviderClient, InitiateAuthCommand } from "@aws-sdk/client-cognito-identity-provider";
import { CognitoIdentityClient, GetIdCommand, GetCredentialsForIdentityCommand } from "@aws-sdk/client-cognito-identity";
// import awsExports from './aws-exports';


const apiRegion = 'us-west-1';
const apiHost = '2uui4xy312';

const userPoolRegion = 'us-west-1';
const userPoolId = 'us-west-1_K7vLvqWfz';
const userPoolHost = 'cognito-idp.'+userPoolRegion+'.amazonaws.com';
const userPoolWebClientId = "24u1kngpf6g138gb6hf18c21rn";

const identityPoolRegion = 'us-west-1';
const identityPoolId = 'us-west-1:18670b9a-7b6a-4c47-b658-fdae4d2adc3e';

const cognitoUserPool = new CognitoIdentityProviderClient({region: userPoolRegion});
const cognitoIdentityPool = new CognitoIdentityClient({region: identityPoolRegion});


async function signIn(username, password) {
    return await cognitoUserPool.send(new InitiateAuthCommand({
        ClientId: userPoolWebClientId,
        AuthFlow: 'USER_PASSWORD_AUTH',
        AuthParameters: {
            USERNAME: username,
            PASSWORD: password,
        }
    })).then((auth) => {
        // console.log('auth: ' + auth)
        return auth;
    });
}


const username = 'example'
const password = 'example'

signIn(username, password).then(r => {
    console.log('authResponse: ' + JSON.stringify(r))
});
// console.log(a)
/*.then(r => {
    console.log(r);
    // return r;
})*//*.then((authResponse) => {
    console.log(authResponse)
    const idToken = authResponse['AuthenticationResult']['IdToken'];
    console.log('idToken: ' + idToken);

    /!*const identityId = user.IdentityId;
    console.log('identityId: ' + identityId)*!/
})*/
// console.log(authResponse)
// const idToken = authResponse['AuthenticationResult']['IdToken'];
// console.log('idToken: ' + idToken);

// Amplify.configure({
//     "version": "1",
//     "auth": {
//         "aws_region": userPoolRegion,
//         "user_pool_id": userPoolId,
//         "user_pool_client_id": "24u1kngpf6g138gb6hf18c21rn",
//         "identity_pool_id": identityPoolId,
//         /*
//         "username_attributes": ["email"],
//         "standard_required_attributes": ["email"],
//         "user_verification_types": ["email"],
//         "unauthenticated_identities_enabled": true,
//         "password_policy": {
//             "min_length": 8,
//             "require_lowercase": true,
//             "require_uppercase": true,
//             "require_numbers": true,
//             "require_symbols": true
//         }
//          */
//     }
//     /*Auth: {
//         mandatorySignIn: false,
//         region: userPoolRegion,
//         userPoolId: userPoolId,
//         userPoolWebClientId: "24u1kngpf6g138gb6hf18c21rn",
//         authenticationFlowType: 'USER_PASSWORD_AUTH',
//     }*/
// })
/*



function _signIn(username, password) {
    return signIn(username, password).then((user) => {
        return user;
    });
}

function _currentSession() {
    return currentSession().then(session => {
        return session;
    })
}

function _authSession() {
    return fetchAuthSession().then(session => {
        return session;
    })
}

_signIn(username, password).then((user) => {
    _authSession().then(s => {
        console.log('s: ' + JSON.stringify(s))
    })

    /!*_currentSession().then(session => {
        // console.log('session: ' + JSON.stringify(session))

        const idToken = session.idToken.getJwtToken()
        console.log('idToken: ' + JSON.stringify(idToken))

        const loginKey = userPoolHost + '/' + userPoolId
        const loginParams = {
            clientConfig: {
                region: identityPoolRegion
            },
            identityPoolId: identityPoolId,
            logins: {
                [loginKey]: idToken,
            }
        }

        const opts = {
            method: "GET",
            service: "execute-api",
            region: apiRegion,
            path: "/v1/hello",
            host: apiHost,
            // headers: { "x-api-key": apiKey },
            url: `https://${apiHost}/v1/hello`
        };
        //
        // const request = aws4.sign(opts, {
        //      accessKeyId,
        //      secretAccessKey,
        //      sessionToken
        // });
    })*!/
});
*/
