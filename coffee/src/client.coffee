###
	Wrapper for 3scale Web Service Management API.
	The constructor requires at least two parameters
		app_id => Application id
		provider_key => Provider key
	
	Example:
	
		var ThreeScale = require("3scale");
		var client = ThreeScale.client('123abc')
###
class Client
	
	constructor: (provider_key, default_host = "su1.3scale.net") ->
		unless provider_key?
			throw "missing provider_key"
		@provider_key = provider_key
		@host = default_host
  
	authorize: (options = {}) ->
		unless options.app_id?
			throw "missing app_id"
	


# Export the module
module.exports = exports = Client