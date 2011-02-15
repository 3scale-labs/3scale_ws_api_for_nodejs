# Client for 3Scale web service
***

#### Requirements

* Parser xml with [node-o3-fastxml](https://github.com/ajaxorg/node-o3-fastxml)

	This module is not available in the package manager npm, so you will need to go to GitHub project page and get the *. node 
	to be placed in the path of node.

#### Installation

The module is delivered through the package manager npm, so that the installation should be:

`npm install 3scale`

Alternatively you can download the sources from the [project page](https://github.com/3scale/3scale_ws_api_for_js), and compile the script files * Coffee for the latest version of the module.

`rake compile`

To make the compilation of sources must be installed in the system Coffee Script:

`npm install coffee-script`

Once compiled these files must be placed in the node path

#### Testing

To run tests:

`rake test`

In the root of the project

#### Usage

```js
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
  sys.log(sys.inspect(response));
});
```