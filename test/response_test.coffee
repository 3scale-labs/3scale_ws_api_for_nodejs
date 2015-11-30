assert = require 'assert'

Response = require('../src/response')

describe 'Basic test for the 3Scale::Response', ->
  describe 'a response', ->
    it 'should have a success method', ->
      response = new Response()
      assert.equal typeof response.success, 'function'

    it 'should have a code & message null after a success', ->
      response = new Response()
      response.success()
      assert.equal response.error_code, null
      assert.equal response.error_message, null

    it 'should have a error method', ->
      response = new Response()
      assert.equal typeof response.error, 'function'

    it 'should have a custom code and message after error', ->
      response = new Response()
      response.error('Error message', 123)
      assert.equal response.error_message, 'Error message'
      assert.equal response.error_code, 123

    it 'should have a custom code and null message after error', ->
      response = new Response()
      response.error('Error message')
      assert.equal response.error_message, 'Error message'
      assert.equal response.error_code, null

    it 'have a is_success method', ->
      response = new Response()
      assert.equal typeof response.is_success, 'function'

    it 'be true after a call to success method', ->
      response = new Response()
      response.success()
      assert response.is_success()

    it 'be false after a error method', ->
      response = new Response()
      response.error('Error message', 123)
      assert.equal response.is_success(), false

