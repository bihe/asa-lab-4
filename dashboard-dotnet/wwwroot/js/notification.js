'use strict';

var connection = new signalR.HubConnectionBuilder().withUrl('/notificationHub').build();

// we use those colors to identify which host is sending the message
// apply a color per host. the "colors" are alert-types of twitter bootstrap
const colors = [
    'alert alert-info',
    'alert alert-warning',
    'alert alert-success',
    'alert alert-danger',
    'alert alert-primary',
    'alert alert-dark',
    'alert alert-secondary',
    'alert alert-light'
];
var hostNames = {};
var lastIndex = 0;

// ok, this is absolutely not necessary but I like it ;)
const tagGolang = '<div style="position: absolute;left: -30px;top: 13px;"><img src="/img/golang.svg" alt="agent-golang"/></div>';
const tagPyhton = '<div style="position: absolute;left: -30px;top: 13px;"><img src="/img/python.svg" alt="agent-python"/></div>'
const tagAgent = '<div style="position: absolute;right: 0px;top: -20px;"><img src="/img/agent.svg" alt="agent-generic" width="40px" height="40px"/></div>'


connection.on('ReceiveNotification', function (host, mac, tstamp, value) {
    if (!(host in hostNames)) {
        hostNames[host] = lastIndex;
        if (lastIndex === (colors.length-1)) {
            lastIndex = 0; // repeat, otherwise array overflow
        }
        else {
            lastIndex++;
        }
    }

    var color = colors[hostNames[host]];
    const message = document.createElement('div');
    message.setAttribute('class', color);
    message.setAttribute('role', 'alert');
    message.innerHTML = `🏠 <strong>${host}</strong> (Mac: <span style="color:green">${mac}</span>)<span class="float-end">[${tstamp}]</span><br/><span class="vr">&nbsp;${value}</span>`;

    if (host.includes('golang')) {
        message.innerHTML += tagGolang;
    } else if (host.includes('python')) {
        message.innerHTML += tagPyhton;
    }
    else {
        message.innerHTML += tagAgent;
    }

    const content = document.getElementById('content');
    content.appendChild(message);

    message.scrollIntoView(); // scroll to it to show it ;)
});

connection.start().then(function () {
    // noop
}).catch(function (err) {
    return console.error(err.toString());
});

// document.getElementById('sendButton').addEventListener('click', function (event) {
//     var user = document.getElementById('userInput').value;
//     var message = document.getElementById('messageInput').value;
//     connection.invoke('SendMessage', user, message).catch(function (err) {
//         return console.error(err.toString());
//     });
//     event.preventDefault();
// });
