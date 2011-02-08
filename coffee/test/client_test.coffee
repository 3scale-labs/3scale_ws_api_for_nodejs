###
	Temporal vars, to make the request, that have been remove form de final relase
	TODO:	REMOVE the vars of the information about the service
###
provider_key = '05273bcb282d1d4faafffeb01e224db0'
app_key = '3e05c797ef193fee452b1ddf19defa74'
app_id = '75165984'

require './common'

# Object to testing
Client = require('./../lib/3scale/client')

client_suite = vows.describe "Basic test for the 3Scale::Client"
client_suite.addBatch(
	'A client Should':
		topic: -> Client
		'to be throw a exception if init without provider_key': (Client) ->
			assert.throws(`function(){ new Client()}`, "missing provider_key")
			return
		
		'to be a default host': (Client) ->
			client = new Client(123)
			assert.equal client.host, "su1.3scale.net"
			return
		
		'to be can change the default host': (Client) ->
			client = new Client(123, 'example.com')
			assert.equal client.host, "example.com"
			return
		
		'to be have a authorize method': (Client) ->
			client = new Client(provider_key)
			assert.isFunction client.authorize
			return
		
		'to be throw a exception if authorize method is called without :app_id': (Client) ->
			client = new Client(provider_key)
			assert.throws client.authorize(), "missing app_id"
			return
		
		'to be return a AuthorizeResponse with the correct :app_id': (client) ->
			
		
).export module
