###
	Temporal vars, to make the request, that have been remove form de final relase
	TODO:	REMOVE the vars of the information about the service
###
provider_key = '05273bcb282d1d4faafffeb01e224db0'
application_key = '3e05c797ef193fee452b1ddf19defa74'
application_id = '75165984'

trans = [
	{ "app_id": application_id, "usage": {"hits": 1}},
	{ "app_id": application_id, "usage": {"hits": 1000}}
]
report_test = {transactions: trans, provider_key: provider_key}

require './common'
log = sys.log
inspect = sys.inspect
events = require('events')

# Object to testing
Client = require('./../lib/3scale/client')

client_suite = vows.describe "Basic test for the 3Scale::Client"
client_suite.addBatch(
	'A client Should':
		topic: -> Client
		'to be throw a exception if init without provider_key': (Client) ->
			assert.throws(`function(){ new Client()}`, "missing provider_key")
			return
		
		'have a default host': (Client) ->
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
			assert.throws client.authorize({}, ()->), "missing app_id"
			return
		
	'In the authorize method should':
		topic: ->
			promise = new events.EventEmitter
			client = new Client provider_key
			client.authorize {app_key: application_key, app_id: application_id}, (response) ->
				if response.is_success
					promise.emit 'success', response
				else
					promise.else 'error', response
			
			promise
			
		
		'call the callback with the AuthorizeResponse': (response) ->
			log inspect response
			assert.isTrue response.is_success()
			
		
		topic: ->
			promise = new events.EventEmitter
			client = new Client provider_key
			client.authorize {app_key: application_key, app_id: application_id + 'ERROR'}, (response) ->
				promise.emit 'success', response
			
			promise
		
		'call the callback with a error response if app_id was wrong': (response) ->
			assert.isFalse response.is_success()
		
		'In the transaction method should':
			topic:->
				promise = new events.EventEmitter
				client = new Client provider_key
				client.report report_test
			
).export module
