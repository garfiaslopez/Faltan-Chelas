'use strict';

//  Module dependencies.

var restify = require('restify');
restify.CORS.ALLOW_HEADERS.push('authorization');

module.exports = function(server, logger) {

    server.use(restify.acceptParser(server.acceptable));
    server.use(restify.queryParser());
    server.use(restify.bodyParser());

    server.use(restify.CORS({
        origins: ['*'],
        headers: ['authorization'],
        methods: ['OPTIONS']
    }));

    server.use(restify.fullResponse());

    // Let's log every incoming request. `req.log` is a "child" of our logger
    // with the following fields added by restify:
    // - a `req_id` UUID (to collate all log records for a particular request)
    // - a `route` (to identify which handler this was routed to)
    server.pre(function (req, res, next) {
        logger.info({url: req.url, method: req.method}, 'Started');
        return next();
    });

    // Let's log every response. Except 404s, MethodNotAllowed,
    // VersionNotAllowed -- see restify's events for these.
    server.on('after', function (req, res, route, error) {
        logger.info( "Finished" );
    });

    server.on('MethodNotAllowed', function (req, res, route, error) {
        if (req.method.toLowerCase() === 'options') {

        var allowHeaders = ['accept', 'accept-version', 'Content-Type', 'api-version', 'request-id', 'origin', 'x-api-version', 'x-request-id', 'authorization'];

        if (res.methods.indexOf('OPTIONS') === -1) res.methods.push('OPTIONS');

            res.header('Access-Control-Allow-Credentials', true);
            res.header('Access-Control-Allow-Headers', allowHeaders.join(', '));
            res.header('Access-Control-Allow-Methods', res.methods.join(', '));
            res.header('Access-Control-Allow-Origin', req.headers.origin);

            logger.info( "Finished" );
            res.send(204);
        }else{
            logger.info( "Finished" );
            res.send(new restify.MethodNotAllowedError());
        }
    });

};
