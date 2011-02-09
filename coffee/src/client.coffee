http = require 'http'
sys = require 'sys'
querystring = require 'querystring'


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
		
		url = "/transactions/authorize.xml?"
		query = querystring.stringify options
		query += '&' + querystring.stringify {provider_key: @provider_key}
		sys.puts query
		
		threescale = http.createClient 80, @host
		request = threescale.request "GET", "#{url}#{query}", {host: @host}
		request.end()
		request.on 'response', (response) ->
			response.setEncoding 'utf8'
			xml = ""
			response.on 'data', (chunk) ->
				xml += chunk
			
			response.on 'end', () ->
				sys.puts xml
			
		
	


# Export the module
module.exports = exports = Client

client = new Client('05273bcb282d1d4faafffeb01e224db0')
client.authorize({app_id: '75165984', app_key: '3e05c797ef193fee452b1ddf19defa74'})