# Set environment variables for tests that run against the 3scale API or use dummy keys
provider_key = process.env.TEST_3SCALE_PROVIDER_KEY
application_key = process.env.TEST_3SCALE_APP_KEY
application_id = process.env.TEST_3SCALE_APP_ID

trans = [
  { "app_id": application_id, "usage": {"hits": 1}},
  { "app_id": application_id, "usage": {"hits": 1000}}
]
report_test = {transactions: trans, provider_key: provider_key}

events = require('events')
vows = require('vows')
assert = require('assert')
nock = require('nock')

# Object to testing
Client = require('../src/client')

vows
  .describe("Basic test for the 3Scale::Client")
  .addBatch
    'A client ':
      topic: -> Client
      'should throw an exception if init without provider_key': (Client) ->
        call = -> new Client()
        assert.throws call, "missing provider_key"
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

    'The oauth_authorize method should': 'TODO'
    ###
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
    ###

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

    'Request headers ':
      topic: ->
        nock.recorder.rec({
          output_objects: true,
          dont_print: true,
          enable_reqheaders_recording: true
        })
        return null

      'in authorize calls':
        topic: ->
          promise = new events.EventEmitter
          client = new Client provider_key
          client.authorize {app_key: application_key, app_id: application_id}, (response) ->
            if response.is_success
              promise.emit 'success', response
            else
              promise.else 'error', response
          promise

        'should include the 3scale user agent': (response) ->
          nock_call_objects = nock.recorder.play()
          last_request_headers = nock_call_objects[0].reqheaders
          version = require('../package.json').version
          assert.equal last_request_headers['x-3scale-user-agent'], "plugin-node-v#{version}"

        'should include the default 3scale host': (response) ->
          nock_call_objects = nock.recorder.play()
          last_request_headers = nock_call_objects[0].reqheaders
          assert.equal last_request_headers['host'], 'su1.3scale.net'

      'in report calls':
        topic: ->
          promise = new events.EventEmitter
          client = new Client provider_key
          client.report report_test, (response) ->
            promise.emit 'success', response
          promise

        'should include the 3scale user agent': (response) ->
          nock_call_objects = nock.recorder.play()
          last_request_headers = nock_call_objects[0].reqheaders
          version = require('../package.json').version
          assert.equal last_request_headers['x-3scale-user-agent'], "plugin-node-v#{version}"

        'should include the default 3scale host': (response) ->
          nock_call_objects = nock.recorder.play()
          last_request_headers = nock_call_objects[0].reqheaders
          assert.equal last_request_headers['host'], 'su1.3scale.net'

  .export module
