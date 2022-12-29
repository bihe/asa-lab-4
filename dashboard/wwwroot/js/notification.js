'use strict';

var connection = new signalR.HubConnectionBuilder().withUrl('/notificationHub').build();

// we use those colors to identify which host is sending the message
// apply a color per host. the "colors" are alert-types of twitter bootstrap
const colors = [
    'alert alert-info',
    'alert alert-warning',
    'alert alert-success',
    'alert alert-primary',
    'alert alert-secondary',
    'alert alert-danger',
    'alert alert-light',
    'alert alert-dark'
];
var hostNames = {};
var lastIndex = 0;



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
