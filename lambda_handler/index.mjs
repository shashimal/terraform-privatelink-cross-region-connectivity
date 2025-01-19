import fetch from 'node-fetch';

export const handler = async (event) => {
    try {
        const VPC_ENDPOINT_DNS = process.env.VPC_ENDPOINT_DNS
        const response = await fetch('http://'+VPC_ENDPOINT_DNS);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.text();

        return {
            statusCode: 200,
            body: JSON.stringify({ message: data }),
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error occurred', error: error.message }),
        };
    }
};
