/*
	Temporal vars, to make the request, that have been remove form de final relase
	TODO:	REMOVE the vars of the information about the service
*/var Client, application_id, application_key, client_suite, events, inspect, log, provider_key;
provider_key = '05273bcb282d1d4faafffeb01e224db0';
application_key = '3e05c797ef193fee452b1ddf19defa74';
application_id = '75165984';
require('./common');
log = sys.log;
inspect = sys.inspect;
events = require('events');
Client = require('./../lib/3scale/client');
client_suite = vows.describe("Basic test for the 3Scale::Client");
client_suite.addBatch({
  'A client Should': {
    topic: function() {
      return Client;
    },
    'to be throw a exception if init without provider_key': function(Client) {
      assert.throws(function(){ new Client()}, "missing provider_key");
    },
    'have a default host': function(Client) {
      var client;
      client = new Client(123);
      assert.equal(client.host, "su1.3scale.net");
    },
    'to be can change the default host': function(Client) {
      var client;
      client = new Client(123, 'example.com');
      assert.equal(client.host, "example.com");
    },
    'to be have a authorize method': function(Client) {
      var client;
      client = new Client(provider_key);
      assert.isFunction(client.authorize);
    },
    'to be throw a exception if authorize method is called without :app_id': function(Client) {
      var client;
      client = new Client(provider_key);
      assert.throws(client.authorize({}, function() {}), "missing app_id");
    }
  },
  'In the authorize method should': {
    topic: function() {
      var client, promise;
      promise = new events.EventEmitter;
      client = new Client(provider_key);
      client.authorize({
        app_key: application_key,
        app_id: application_id
      }, function(response) {
        if (response.is_success) {
          return promise.emit('success', response);
        } else {
          return promise["else"]('error', response);
        }
      });
      return promise;
    },
    'call the callback with the AuthorizeResponse': function(response) {
      log(inspect(response));
      return assert.isTrue(response.is_success());
    },
    topic: function() {
      var client, promise;
      promise = new events.EventEmitter;
      client = new Client(provider_key);
      client.authorize({
        app_key: application_key,
        app_id: application_id + 'ERROR'
      }, function(response) {
        return promise.emit('success', response);
      });
      return promise;
    },
    'call the callback with a error response if app_id was wrong': function(response) {
      return assert.isFalse(response.is_success());
    }
  }
})["export"](module);