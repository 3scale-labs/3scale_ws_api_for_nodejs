/*
	Wrapper for 3scale Web Service Management API.
	The constructor requires at least two parameters
		app_id => Application id
		provider_key => Provider key

	Example:

		var ThreeScale = require("3scale");
		var client = ThreeScale.client('123abc')
*/var Client, exports;
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
    if (options == null) {
      options = {};
    }
    if (options.app_id == null) {
      throw "missing app_id";
    }
  };
  return Client;
})();
module.exports = exports = Client;