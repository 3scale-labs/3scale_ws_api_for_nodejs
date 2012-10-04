###
  Temporal vars, to make the request, that have been remove form de final relase
  TODO: REMOVE the vars of the information about the service
###

###
  TODO: remove these keys and parameterize the tests!
  Default 3scale Keys
  Supports basic authentication
###
provider_key = '05273bcb282d1d4faafffeb01e224db0'
application_key = '3e05c797ef193fee452b1ddf19defa74'
application_id = '75165984'  

trans = [
  { "app_id": application_id, "usage": {"hits": 1}},
  { "app_id": application_id, "usage": {"hits": 1000}}
]
report_test = {transactions: trans, provider_key: provider_key}

events = require('events')
vows = require('vows')
assert = require('assert')

# Object to testing
Client = require('../src/client')

vows
  .describe("Basic test for the 3Scale::Client")
  .addBatch
    'A client ':
      topic: -> Client
      'should throw an exception if init without provider_key': (Client) ->
        assert.throws(`function(){ new Client()}`, "missing provider_key")
        return

      'should have an default host': (Client) ->
        client = new Client(123)
        assert.equal client.host, "su1.3scale.net"
        return

      'can change the default host': (Client) ->
        client = new Client(123, 'example.com')
        assert.equal client.host, "example.com"
        return

      'should have an authorize method': (Client) ->
        client = new Client(provider_key)
        assert.isFunction client.authorize
        return

      'should throw an exception if authorize method is called without :app_id': (Client) ->
        client = new Client(provider_key)
        assert.throws (() -> client.authorize({}, () ->)),  "missing app_id"
        return

      'should have an oauth_authorize method': (Client) ->
        client = new Client(provider_key)
        assert.isFunction client.oauth_authorize
        return

      'should throw an exception if oauth_authorize method is called without :app_id': (Client) ->
        client = new Client(provider_key)
        assert.throws (() ->  client.oauth_authorize({}, () ->)), "missing app_id"
        return

      'should have an authorize_with_user_key method': (Client) ->
        client = new Client(provider_key)
        assert.isFunction client.authorize_with_user_key
        return

      'should throw an exception if authorize_with_user_key is called without :user_key': (Client) ->
        client = new Client(provider_key)
        assert.throws (() -> client.authorize_with_user_key({}, () ->)), "missing user_key"
        return

      'should have an authrep method': (Client) ->
        client = new Client(provider_key)
        assert.isFunction client.authrep
        return

      'should throw an exception if authrep called without :app_id': (Client) ->
        client = new Client(provider_key)
        assert.throws (() -> client.authrep({}, () ->)), "missing app_id"
        return

      'should have an authrep_with_user_key method': (Client) ->
        client = new Client(provider_key)
        assert.isFunction client.authrep_with_user_key

      'should throw an exception if authrep_with_user_key is called without :user_key': (Client) ->
        client = new Client(provider_key)
        assert.throws (() -> client.authrep_with_user_key({}, ()->)), 'missing user_key'  

    'The authorize method should':
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
        assert.isTrue response.is_success()

    'The oauth_authorize method should':
      topic: ->
        promise = new events.EventEmitter
        client = new Client oauth_provider_key
        client.oauth_authorize {app_id: oauth_application_id}, (response) ->
          if response.is_success
            promise.emit 'success', response
          else
            promise.else 'error', response

        promise

      'call the callback with the AuthorizeResponse': (response) ->
        assert.isTrue response.is_success()

    'The authorize_with_user_key method should':
      topic: ->
        promise = new events.EventEmitter
        client = new Client senico_provider_key
        client.authorize_with_user_key {user_key: senico_user_key}, (response) ->
          if response.is_success
            promise.emit 'success', response
          else
            promise.else 'error', response

        promise

      'call the callback with the AuthorizeResponse': (response) ->
        assert.isTrue response.is_success()

    'The Event Emitter':  
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
          client.report report_test, (response) ->
            promise.emit 'success', response

          promise

        'give a success response with the correct params': (response) ->
          assert.isTrue response.is_success()     
  .export module
