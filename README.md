# 3scale integration plugin for JavaScript/CoffeeScript/Node.js applications [![Build Status](https://secure.travis-ci.org/3scale/3scale_ws_api_for_nodejs.png?branch=master)](http://travis-ci.org/3scale/3scale_ws_api_for_nodejs)

3scale is an API Infrastructure service which handles API Keys, Rate Limiting, Analytics, Billing Payments and Developer Management.
Includes a configurable API dashboard and developer portal CMS.
More product stuff at http://www.3scale.net/, support information at http://support.3scale.net/.

#### Requirements

* libxml2 library

#### Installation

The module is delivered through the package manager npm, so that the installation should be easy as: `npm install 3scale`

#### Testing

To run tests: `vows test/* --spec`

In the root of the project.

#### Usage

    var Client = require('3scale').Client;

    client = new Client("your provider key");

    client.authorize({app_id: "your application id", app_key: "your application key"}, function(response){
      sys.log(sys.inspect(response));
    });

    // Or for reports

    var trans = [
                  { "app_id": "your application id", "usage": {"hits": 1}},
                  { "app_id": "your application id", "usage": {"hits": 1000}}
                 ]

    client.report(trans, function(response){
      console.log(response);
    });

