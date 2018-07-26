'use strict';

module.exports = {
    //For generate 32bytes & 64bytes :     openssl rand -base64 64
    port: 3000,
    APIURL: 'http://localhost:3000',
    baseURL: 'http://localhost:3000',
    mongodb: 'mongodb://localhost:27017/FaltanChelasDB',
    key: 'MyLittleAndSecretKeyForFaltanChelas',
    encKey: '0uSd08jUKU4Q55dg/mU5etSJZmAJYbDrQ6p3KBGTIcg=',
    sigKey: 'fmvqmdoDcyWPoqjL/h8sqJ2HguI0bQwvGLfnGuXj96saU3T+ru4E15orFyh0O5OEz63DWj150m4N17s1pv0Djg==',
    ConektaApiKey: 'key_HYzhThVhjay9HfTiykYeGg',
    UrbanAppKey: '2S_HJOwvS5aPEvZZazjgrw',
    UrbanMasterSecret: '96YA2uRjTpmKvfrnGptOAQ',
    app: {
        name: 'FaltanChelas Development',
    },
    searchDistance: 2000,
    searchLimit: 10
};
