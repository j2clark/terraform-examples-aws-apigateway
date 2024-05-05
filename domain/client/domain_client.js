const axios = require('axios');

const config = {
    region: 'us-west-1',
    domain: null,
    endpoint: '/hello'
}

const args = process.argv.splice(2)
args.forEach((val) => {
    const key = val.split("=")[0]
    console.log()
    switch (key) {
        case 'DOMAIN':
            config['domain'] = val.split("=")[1];
            break
        case 'ENDPOINT':
            config['endpoint'] = val.split("=")[1];
            break
        case 'REGION':
            config['region'] = val.split("=")[1];
            break
    }
})

if (!config['domain']) {
    throw new Error('DOMAIN parameter required')
}

const url = 'https://api.' + config.domain + config.endpoint;
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
