exports.handler = async (event) => {
    console.log('event: ' + JSON.stringify(event))
    // Your Lambda function logic here

    const response = {
        message: "Hello from awsiam!"
    };

    return response;
};

