var express = require('express');
var app = express();

app.use(express.static('src'));
app.use(express.static('../SmartLease-Contract/build/contracts'));
app.use(express.json());


app.get('/', function (req, res) {
  res.render('index.html');
});

if (typeof localStorage === "undefined" || localStorage === null) {
  LocalStorage = require('node-localstorage').LocalStorage;
  localStorage = new LocalStorage('./src');
  localStorage.removeItem('flagIndex')
}

if(localStorage.getItem('flagIndex')==='undefined' || localStorage.getItem('flagIndex')===null ) {
  localStorage.setItem('flagIndex.json', Math.floor((Math.random() * 243) + 1));
}

app.listen(3010, function () {
  console.log('Smart Lease Dapp listening on port 3010!');
});


