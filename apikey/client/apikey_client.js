const axios = require('axios');

const config = {
    region: 'us-west-1',
    apiId: null,
    apikey: null,
    endpoint: '/v1/hello'

}

const args = process.argv.splice(2)
args.forEach((val) => {
    const key = val.split("=")[0]
    console.log()
    switch (key) {
        case 'API':
            config['apiId'] = val.split("=")[1];
            break
        case 'APIKEY':
            config['apikey'] = val.split("=")[1];
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
    throw new Error('API parameter required')
}
if (!config['apikey']) {
    throw new Error('APIKEY parameter required')
}

const url = 'https://' + config.apiId + '.execute-api.' + config.region + '.amazonaws.com' + config.endpoint;
console.log('url: ' + url);
axios.get(url, {
    headers: {
        "Content-type": "application/json",
        'x-api-key': config.apikey
    }
}).then(response => {
    console.log('SUCCESS! ' + JSON.stringify(response.data));
}).catch(err => {
    console.log('ERROR! ' + err);

    console.log('DID YOU MANUALLY DEPLOY API? ' + err);
});
