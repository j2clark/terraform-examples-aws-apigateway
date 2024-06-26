/*
usage: node ./cors_client.js API_ID=fc1dnxkb81
 */

const axios = require('axios');

const config = {
    region: 'us-west-1',
    apiId: null,
    endpoint: '/v1/hello'
}

const args = process.argv.splice(2)
args.forEach((val) => {
    const key = val.split("=")[0]
    console.log()
    switch (key) {
        case 'API_ID':
            config['apiId'] = val.split("=")[1];
            break
        case 'ENDPOINT':
            config['endpoint'] = val.split("=")[1];
            break
        case 'REGION':
            config['region'] = val.split("=")[1];
            break
    }
})

if (!config['apiId']) {
    throw new Error('API_ID parameter required')
}

const url = 'https://' + config.apiId + '.execute-api.' + config.region + '.amazonaws.com' + config.endpoint;
console.log('url: ' + url);
axios.get(url, {
    headers: {
        "Content-type": "application/json"
    }
}).then(response => {
    console.log('SUCCESS! ' + JSON.stringify(response.data));
}).catch(err => {
    console.log('ERROR! ' + err);

    console.log('DID YOU MANUALLY DELETE hello OPTIONS, ! ' + err);
});
