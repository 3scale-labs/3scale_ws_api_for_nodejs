var Client, client, exports, http, querystring, sys;
http = require('http');
sys = require('sys');
querystring = require('querystring');
/*
	Wrapper for 3scale Web Service Management API.
	The constructor requires at least two parameters
		app_id => Application id
		provider_key => Provider key

	Example:

		var ThreeScale = require("3scale");
		var client = ThreeScale.client('123abc')
*/
Client = (function() {
  function Client(provider_key, default_host) {
    if (default_host == null) {
      default_host = "su1.3scale.net";
    }
    if (provider_key == null) {
      throw "missing provider_key";
    }
    this.provider_key = provider_key;
    this.host = default_host;
  }
  Client.prototype.authorize = function(options) {
    var query, request, threescale, url;
    if (options == null) {
      options = {};
    }
    if (options.app_id == null) {
      throw "missing app_id";
    }
    url = "/transactions/authorize.xml?";
    query = querystring.stringify(options);
    query += '&' + querystring.stringify({
      provider_key: this.provider_key
    });
    sys.puts(query);
    threescale = http.createClient(80, this.host);
    request = threescale.request("GET", "" + url + query, {
      host: this.host
    });
    request.end();
    return request.on('response', function(response) {
      var xml;
      response.setEncoding('utf8');
      xml = "";
      response.on('data', function(chunk) {
        return xml += chunk;
      });
      return response.on('end', function() {
        return sys.puts(xml);
      });
    });
  };
  return Client;
})();
module.exports = exports = Client;
client = new Client('05273bcb282d1d4faafffeb01e224db0');
client.authorize({
  app_id: '75165984',
  app_key: '3e05c797ef193fee452b1ddf19defa74'
});