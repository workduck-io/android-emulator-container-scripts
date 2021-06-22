var net = require('net');

const sourceport = 1720;
const destport = 1717;

net.createServer(function (s) {
    var buff = "";
    var connected = false;
    var cli = net.createConnection(destport);
    s.on('data', function (d) {
        if (connected) {
            cli.write(d);
        } else {
            buff += d.toString();
        }
    });
    cli.on('connect', function () {
        connected = true;
        console.log(buff);
        cli.write(buff);
    });
    cli.pipe(s);
}).listen(sourceport);