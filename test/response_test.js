var Response, response_suite;
require('./common');
Response = require('./../lib/3scale/response');
response_suite = vows.describe("Basic test for the 3Scale::Response");
response_suite.addBatch({
  'A response Should': {
    topic: function() {
      return new Response();
    },
    'have a success method': function(response) {
      return assert.isFunction(response.success);
    },
    'have a code & message null after a success': function(response) {
      response.success();
      assert.isNull(response.error_code);
      return assert.isNull(response.error_message);
    },
    'have a error method': function(response) {
      return assert.isFunction(response.error);
    },
    'have a custom code and message after error': function(response) {
      response.error('Error message', 123);
      assert.equal(response.error_message, 'Error message');
      return assert.equal(response.error_code, 123);
    },
    'have a is_success method': function(response) {
      return assert.isFunction(response.is_success);
    },
    'be true after a call to success method': function(response) {
      response.success();
      return assert.isTrue(response.is_success());
    },
    'be false after a error method': function(response) {
      response.error('Error message', 123);
      return assert.isFalse(response.is_success());
    }
  }
})["export"](module);