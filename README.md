# 3scale integration plugin for JavaScript/CoffeeScript/Node.js applications [![Build Status](https://secure.travis-ci.org/3scale/3scale_ws_api_for_nodejs.png?branch=master)](http://travis-ci.org/3scale/3scale_ws_api_for_nodejs)

3scale is an API Infrastructure service which handles API Keys, Rate Limiting, Analytics, Billing Payments and Developer Management.
Includes a configurable API dashboard and developer portal CMS.
More product stuff at http://www.3scale.net/, support information at http://support.3scale.net/.

## Requirements

* libxml2 library

Starting at version 0.5.0, this plugin requires using **Node.js versions 0.8.x or higher**. Node.js 0.6.x is no longer supported due to incompatibilities that break the tests.


## Synopsis

This plugin supports the 3 main calls to the 3scale backend:

- authrep grants access to your API and reports the traffic on it in one call.
- authorize grants access to your API.
- report reports traffic on your API.

3scale supports 3 authentication modes: App Id, User Key and OAuth. The first two are similar on their calls to the backend, they support authrep. OAuth differs in its usage two calls are required: first authorize then report.

## Installation

The module is delivered through the package manager npm, so that the installation should be easy as: `npm install 3scale`

## Usage

### Authrep

Authrep is a 'one-shot' operation to authorize an application and report the associated transaction at the same time. The main difference between this call and the regular **authorize** call is that usage will be reported if the authorization is successful. Read more about authrep at the active docs page on the [3scale's support site](https://support.3scale.net/reference/active-docs).

```javascript
var Client = require('3scale').Client;

client = new Client("your provider key");

client.authrep({"app_id": "your application id", "app_key": "your application key", "usage": { "hits": 1 } }, function(response){
  sys.log(sys.inspect(response));
});
```

### Authorize and Report

You can alternatively use the **authorize** and **report** methods to do the same in two separate calls. 
Note that the **report** method supports sending the usage for multiple transactions in a single call.

```javascript
var Client = require('3scale').Client;

client = new Client("your provider key");

client.authorize({"app_id": "your application id", "app_key": "your application key"}, function(response){
  if (response.is_success()) {
    var trans = [{"app_id": "your application id", "usage": {"hits": 3}}];
    client.report(trans, function (response) {
      console.log(response);
    });
  } 
  else {
    console.log("Error: " + response.error_code + " msg: " + response.error_msg);
  }
});
```

Note that the **report** method supports sending the usage for multiple transactions in a single call.

```javascript
var trans = [
              { "app_id": "your application id", "usage": {"hits": 1}},
              { "app_id": "your application id", "usage": {"hits": 1000}}
             ]

client.report(trans, function(response){
  console.log(response);
});
```

### OAuth

If you set OAuth as the authentication pattern for your API in 3scale, you will need to take the separate **authorize** and **report** approach (i.e. there is no **authrep** for OAuth).

```javascript
var Client = require('3scale').Client;

client = new Client("your provider key");

client.oauth_authorize({"app_id": "your application id"}, function(response){
  if (response.is_success()) {
    var trans = [{"app_id": "your application id", "usage": {"hits": 3}}];
    client.report(trans, function (response) {
      console.log(response);
    });
  } 
  else {
    console.log("Error: " + response.error_code + " msg: " + response.error_msg);
  }
});
```

## To test

To run tests: `npm test` or `vows test/* --spec` from the root directory of the project.
Please note that you will first need to set the following environment variables using your own 3scale keys:

- TEST_3SCALE_PROVIDER_KEY
- TEST_3SCALE_APP_KEY
- TEST_3SCALE_APP_ID
