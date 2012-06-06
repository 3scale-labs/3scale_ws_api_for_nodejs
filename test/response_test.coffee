vows = require 'vows'
assert = require 'assert'

# Object to testing
Response = require('../src/response')

vows
  .describe("Basic test for the 3Scale::Response")
  .addBatch
    'A response Should':
      topic: -> new Response()
      'have a success method': (response) ->
        assert.isFunction response.success

      'have a code & message null after a success': (response) ->
        response.success()
        assert.isNull(response.error_code)
        assert.isNull(response.error_message)

      'have a error method': (response) ->
        assert.isFunction response.error

      'have a custom code and message after error': (response) ->
        response.error('Error message', 123)
        assert.equal response.error_message, 'Error message'
        assert.equal response.error_code, 123

      'have a custom code and null message after error': (response) ->
        response.error('Error message')
        assert.equal response.error_message, 'Error message'
        assert.isNull response.error_code

      'have a is_success method': (response) ->
        assert.isFunction response.is_success

      'be true after a call to success method': (response) ->
        response.success()
        assert.isTrue response.is_success()

      'be false after a error method': (response) ->
        response.error('Error message', 123)
        assert.isFalse response.is_success()
		
  .export(module)
