/*
	Temporal vars, to make the request, that have been remove form de final relase
	TODO:	REMOVE the vars of the information about the service
*/var Client, app_id, app_key, client_suite, provider_key;
provider_key = '05273bcb282d1d4faafffeb01e224db0';
app_key = '3e05c797ef193fee452b1ddf19defa74';
app_id = '75165984';
require('./common');
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
    'to be a default host': function(Client) {
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
      assert.throws(client.authorize(), "missing app_id");
    },
    'to be return a AuthorizeResponse with the correct :app_id': function(client) {}
  }
})["export"](module);