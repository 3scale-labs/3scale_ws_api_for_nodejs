# 3scale integration plugin for JavaScript/CoffeeScript/Node.js applications [![Build Status](https://secure.travis-ci.org/3scale/3scale_ws_api_for_nodejs.png?branch=master)](http://travis-ci.org/3scale/3scale_ws_api_for_nodejs)

3scale is an API Infrastructure service which handles API Keys, Rate Limiting, Analytics, Billing Payments and Developer Management.
Includes a configurable API dashboard and developer portal CMS.
More product stuff at http://www.3scale.net/, support information at http://support.3scale.net/.

## Installation

The module is delivered through the package manager npm, so that the installation should be easy as: `npm install 3scale`


## Requirements

Starting at version 0.6.0, this plugin requires using **Node.js versions 0.10.x or higher**.


## Synopsis

This plugin supports the 3 main calls to the 3scale Service Management API:

- authrep grants access to your API and reports the traffic on it in one call.
- authorize grants access to your API.
- report reports traffic on your API.

3scale supports 3 authentication modes: App Id, User Key and OAuth. The first two are similar on their calls to the Service Management API, they support authrep. OAuth differs in its usage two calls are required: first authorize then report.

## Usage

> NOTE: From November 2016 `service_id` is mandatory.

### Authrep

Authrep is a 'one-shot' operation to authorize an application and report the associated transaction at the same time. The main difference between this call and the regular **authorize** call is that usage will be reported if the authorization is successful. Read more about authrep at the active docs page on the [3scale's support site](https://support.3scale.net/reference/active-docs).

Here is an example assuming that you are using the `app_id/app_key` authentication mode:
```javascript

var Client = require('3scale').Client;

//Create a Client with a given host and port when connecting to an on-premise instance of the 3scale platform:
client = new Client({host: "service_management_api.example.com", port: 80});

/* or create a Client with default host and port. This will comunicate with the 3scale platform SaaS default server:
client = new Client();
*/

client.authrep({ service_token: "your service token", service_id: "your service id", app_id: "your application id", app_key: "your application key", usage: { "hits": 1 } }, function(response){
  console.log(response);
});

/* If you don't use service_token in the method, you'll be expected to specify a provider_key parameter in the Client instance, which is deprecated in favor of using service_token in the method.

Create a Client with a given host and port:
client = new Client("your provider key",{host: "service_management_api.example.com", port: 80});

or 

Create a Client with default host and port.This will comunicate with the 3scale platform SaaS default server:
client = new Client("your provider key");

client.authrep({ service_id: "your service id", app_id: "your application id", app_key: "your application key", usage: { "hits": 1 } }, function(response){
  console.log(response);
});
*/
```

In case you have your API authentication configured in 3scale to use the `user_key` mode, this would be the equivalent to the example above:

```javascript
var Client = require('3scale').Client;

//Create a Client with a given host and port when connecting to an on-premise instance of the 3scale platform:
client = new Client({host: "service_management_api.example.com", port: 80});

/* or create a Client with default host and port. This will comunicate with the 3scale platform SaaS default server:
client = new Client();
*/

client.authrep_with_user_key({ service_token: "your service token", service_id: "your service id", user_key: "your key", usage: { "hits": 1 } }, function(response){
  console.log(response);
});


/* If you don't use service_token in the method, you'll be expected to specify a provider_key parameter in the Client instance, which is deprecated in favor of using service_token in the method.

Create a Client with a given host and port:
client = new Client("your provider key",{host: "service_management_api.example.com", port: 80});

or 

Create a Client with default host and port.This will comunicate with the 3scale platform SaaS default server:
client = new Client("your provider key");

client.authrep_with_user_key({ "service_id": "your service id", "user_key": "your key", "usage": { "hits": 1 } }, function(response){
  console.log(response);
});

*/
```


If you use `OAuth` as authentication mode, this would be the equivalent to the examples above:

```javascript
var Client = require('3scale').Client;

//Create a Client with a given host and port when connecting to an on-premise instance of the 3scale platform:
client = new Client({host: "service_management_api.example.com", port: 80});

/* or create a Client with default host and port. This will comunicate with the 3scale platform SaaS default server:
client = new Client();
*/

client.oauth_authrep({ service_token: "your service token", service_id: "your service id", app_id: "your Client id", usage: { "hits": 1 } }, function(response){
  console.log(response);
});


/* If you don't use service_token in the method, you'll be expected to specify a provider_key parameter in the Client instance, which is deprecated in favor of using service_token in the method.

Create a Client with a given host and port:
client = new Client("your provider key",{host: "service_management_api.example.com", port: 80});

or 

Create a Client with default host and port.This will comunicate with the 3scale platform SaaS default server:
client = new Client("your provider key");

client.oauth_authrep({ service_id: "your service id", app_id: "your Client id" , usage: { "hits": 1 } }, function(response){
  console.log(response);
});

*/
```

### Authorize and Report

You can alternatively use the **authorize** and **report** methods to do the same in two separate calls. 
Note that the **report** method supports sending the usage for multiple transactions in a single call.


If you use the authentication mode with `app_id` and `app_key pair:
```javascript
var Client = require('3scale').Client;

//Create a Client with a given host and port when connecting to an on-premise instance of the 3scale platform:
client = new Client({host: "service_management_api.example.com", port: 80});

/* or create a Client with default host and port. This will comunicate with the 3scale platform SaaS default server:
client = new Client();
*/

client.authorize({ service_token: "your service token", service_id: "your service id", app_id: "your application id", app_key: "your application key" }, function(response){
  if (response.is_success()) {
    var trans = [{ service_token: "your service token", app_id: "your application id", usage: { "hits": 3 } }];
    client.report("your service id", trans, function (response) {
      console.log(response);
    });
  } 
  else {
    console.log("Error: " + response.error_code + " msg: " + response.error_msg);
  }
});

/* If you don't use service_token in the method, you'll be expected to specify a provider_key parameter in the Client instance, which is deprecated in favor of using service_token in the method.

Create a Client with a given host and port:
client = new Client("your provider key",{host: "service_management_api.example.com", port: 80});

or 

Create a Client with default host and port. This will comunicate with the 3scale platform SaaS default server:
client = new Client("your provider key");

client.authorize({service_id: "your service id", app_id: "your application id", app_key: "your application key" }, function(response){
  if (response.is_success()) {
    var trans = [{ app_id: "your application id", usage: { "hits": 3 } }];
    client.report("your service id", trans, function (response) {
      console.log(response);
    });
  } 
  else {
    console.log("Error: " + response.error_code + " msg: " + response.error_msg);
  }
});
*/
```

Here is the same example for the `user_key` authentication pattern:

```javascript
var Client = require('3scale').Client;

//Create a Client with a given host and port when connecting to an on-premise instance of the 3scale platform:
client = new Client({host: "service_management_api.example.com", port: 80});

/* or create a Client with default host and port. This will comunicate with the 3scale platform SaaS default server:
client = new Client();
*/

client.authorize_with_user_key({ service_token: "your service token", service_id: "your service id", user_key: "your key" }, function(response){
  if (response.is_success()) {
    var trans = [{ service_token: "your service token", user_key: "your key", usage: { "hits": 3 } }];
    client.report("your service id", trans, function (response) {
      console.log(response);
    });
  } 
  else {
    console.log("Error: " + response.error_code + " msg: " + response.error_msg);
  }
});

/* If you don't use service_token in the method, you'll be expected to specify a provider_key parameter in the Client instance, which is deprecated in favor of using service_token in the method.

Create a Client with a given host and port:
client = new Client("your provider key",{host: "service_management_api.example.com", port: 80});

or 

Create a Client with default host and port. This will comunicate with the 3scale platform SaaS default server:
client = new Client("your provider key");

client.authorize_with_user_key({ service_id: "your service id", user_key: "your key" }, function(response){
  if (response.is_success()) {
    var trans = [{ user_key: "your key", usage: { "hits": 3 } }];
    client.report("your service id", trans, function (response) {
      console.log(response);
    });
  } 
  else {
    console.log("Error: " + response.error_code + " msg: " + response.error_msg);
  }
});
*/
```

For `OAuth` as the authentication mode:

```javascript
var Client = require('3scale').Client;

//Create a Client with a given host and port when connecting to an on-premise instance of the 3scale platform:
client = new Client({host: "service_management_api.example.com", port: 80});

/* or create a Client with default host and port. This will comunicate with the 3scale platform SaaS default server:
client = new Client();
*/

client.oauth_authorize({ service_token: "your service token", service_id: "your service id", app_id: "your Client Id" }, function(response){
  if (response.is_success()) {
    var trans = [{ service_token: "your service token", app_id: "your application id", usage: {"hits": 3} }];
    client.report("your service id", trans, function (response) {
      console.log(response);
    });
  } 
  else {
    console.log("Error: " + response.error_code + " msg: " + response.error_msg);
  }
});

/* If you don't use service_token in the method, you'll be expected to specify a provider_key parameter in the Client instance, which is deprecated in favor of using service_token in the method.

Create a Client with a given host and port:
client = new Client("your provider key",{host: "service_management_api.example.com", port: 80});

or 

Create a Client with default host and port. This will comunicate with the 3scale platform SaaS default server:
client = new Client("your provider key");

client.oauth_authorize({ "service_id": "your service id", "app_id": "your application id" }, function(response){
  if (response.is_success()) {
    var trans = [{ app_id: "your application id", usage: {"hits": 3} }];
    client.report("your service id", trans, function (response) {
      console.log(response);
    });
  } 
  else {
    console.log("Error: " + response.error_code + " msg: " + response.error_msg);
  }
});
*/
```

Note that the **report** method supports sending the usage for multiple transactions in a single call.

```javascript
var trans = [
              { service_token: "your service token", app_id: "your application id", usage: {"hits": 1} },
              { service_token: "your service token", app_id: "your application id", usage: {"hits": 1000} }
             ]

client.report("your service id", trans, function(response){
  console.log(response);
});
```

## To test

To run tests: `npm test` or `vows test/* --spec` from the root directory of the project.
Please note that you will first need to set the following environment variables using your own 3scale keys:

- TEST_3SCALE_PROVIDER_KEY
- TEST_3SCALE_APP_KEY
- TEST_3SCALE_APP_ID
