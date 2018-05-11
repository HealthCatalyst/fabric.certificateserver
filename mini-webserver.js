var express = require('express');
var app = express();
var morgan = require('morgan');
var serveIndex = require('serve-index');

var port = process.env.PORT0 || 3000;
var host = process.env.HOST || "0.0.0.0";

app.use(morgan('combined'));
app.use(express.static(__dirname + '/public'));
app.use('/', serveIndex(__dirname + '/public'));

app.get('/status', function (req, res) {
    console.log('Hello from the Certificate Webserver!')
    res.send('Hello from the Certificate Webserver!');
});

app.use(function (req, res, next) {
    res.status(404).end();
});

// log every call: https://stackoverflow.com/questions/46675580/node-express-print-every-http-message-to-console
app.use('/', (req, res, next) => {
    var data = ''
    res.on('data', chunk => { data += chunk })
    res.on('end', () => {
        console.log(data)
    })

    next()
})

var server = app.listen(port, host);


// for SSL use: https://stackoverflow.com/questions/11804202/how-do-i-setup-a-ssl-certificate-for-an-express-js-server