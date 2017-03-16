assert = require 'assert'
nock   = require 'nock'

trans = [
  { 'app_id': 'foo', 'usage': { 'hits': 1 } },
  { 'app_id': 'foo', 'usage': { 'hits': 1000 } }
]
report_test = {service_id: '1234567890987', transactions: trans}

trans_service_token = [
  { 'service_token': '12sdtsdr23454sdfsdf', 'app_id': 'foo', 'usage': { 'hits': 1 } },
  { 'service_token': '12sdtsdr23454sdfsdf', 'app_id': 'foo', 'usage': { 'hits': 1000 } }
]
report_test_service_token = {service_id: '1234567890987', transactions: trans_service_token}


Client = require('../src/client')

describe 'Basic test for the 3Scale::Client', ->
  describe 'A client', ->
    it 'should have a default host', ->
      client = new Client('123')
      assert.equal client.host,'su1.3scale.net'

    it 'can change the default host', ->
      client = new Client('123', {host: 'example.com'})
      assert.equal client.host, 'example.com'

    it 'should have a default port', ->
      client = new Client('123', {host: 'example.com'})
      assert.equal client.port, 443

    it 'can change the default port', ->
      client = new Client('123', {host: 'example.com', port: 3000})
      assert.equal client.port, 3000

    it 'should have an authorize method with provider_key', ->
      client = new Client('1234abcd')
      assert.equal typeof client.authorize, 'function'

    it 'should have an oauth_authorize method with service_token', ->
      client = new Client()
      assert.equal typeof client.oauth_authorize, 'function'

    it 'should have an authorize_with_user_key method with provider_key', ->
      client = new Client('1234abcd')
      assert.equal typeof client.authorize_with_user_key, 'function'

    it 'should have an authrep method with service_token', ->
      client = new Client()
      assert.equal typeof client.authrep, 'function'

    it 'should have an authrep_with_user_key method with provider_key', ->
      client = new Client('1234abcd')
      assert.equal typeof client.authrep_with_user_key, 'function'

    it 'should have an oauth_authrep method with app_id', ->
      client = new Client('1234abcd')
      assert.equal typeof client.oauth_authrep, 'function'




  describe 'The authorize method', ->
    it 'should throw an exception if is called without :app_id', ->
      client = new Client()
      assert.throws (() -> client.authorize({}, () ->)), 'missing app_id'

    it 'should call the callback with a successful response with provider_key', (done) ->
      nock('https://su1.3scale.net')
        .get('/transactions/authorize.xml')
        .query({ service_id: '1234567890987', app_key: 'bar', app_id: 'foo', provider_key: '1234abcd'})
        .reply(200, '<status><authorized>true</authorized><plan>Basic</plan></status>')

      client = new Client '1234abcd'
      client.authorize {service_id: '1234567890987', app_key: 'bar', app_id: 'foo'}, (response) ->
        assert response.is_success()
        assert.equal response.status_code, 200
        done()

    it 'should call the callback with a successful response with service_token', (done) ->
      nock('https://su1.3scale.net')
        .get('/transactions/authorize.xml')
        .query({ service_id: '1234567890987', app_key: 'bar', app_id: 'foo', service_token: '12sdtsdr23454sdfsdf' })
        .reply(200, '<status><authorized>true</authorized><plan>Basic</plan></status>')

      client = new Client 
      client.authorize {service_token: '12sdtsdr23454sdfsdf', service_id: '1234567890987', app_key: 'bar', app_id: 'foo'}, (response) ->
        assert response.is_success()
        assert.equal response.status_code, 200
        done()

    it 'should call the callback with a error response if app_id was wrong', (done) ->
      nock('https://su1.3scale.net')
        .get('/transactions/authorize.xml')
        .query({ service_id: '1234567890987', app_key: 'bar', app_id: 'ERROR', provider_key: '1234abcd'})
        .reply(403, '<error code="application_not_found">application with id="ERROR" was not found</error>')

      client = new Client '1234abcd'
      client.authorize {service_id: '1234567890987', app_key: 'bar', app_id: 'ERROR'}, (response) ->
        assert.equal response.is_success(), false
        assert.equal response.status_code, 403
        done()
    after ->
      nock.cleanAll()


  describe 'The authorize_with user_key method', ->
    it 'should throw an exception if is called without :user_key', ->
      client = new Client()
      assert.throws (() -> client.authorize_with_user_key({}, () ->)), 'missing user_key'

    it 'should call the callback with a error response if user_key was wrong', (done) ->
      nock('https://su1.3scale.net')
        .get('/transactions/authorize.xml')
        .query({ service_id: '1234567890987', user_key: 'ERROR', provider_key: '1234abcd'})
        .reply(403, '<error code="application_not_found">application with id="ERROR" was not found</error>')

      client = new Client '1234abcd'
      client.authorize_with_user_key {service_id: '1234567890987', user_key: 'ERROR'}, (response) ->
        assert.equal response.is_success(), false
        assert.equal response.status_code, 403
        done()
    after ->
      nock.cleanAll()


  describe 'The oauth_authorize method', ->
    it 'should throw an exception if is called without :app_id', ->
      client = new Client()
      assert.throws (() ->  client.oauth_authorize({}, () ->)), 'missing app_id'

    it 'should call the callback with a error response if app_id was wrong', (done) ->
      nock('https://su1.3scale.net')
        .get('/transactions/oauth_authorize.xml')
        .query({ service_id: '1234567890987', app_id: 'ERROR', provider_key: '1234abcd'})
        .reply(403, '<error code="application_not_found">application with id="ERROR" was not found</error>')

      client = new Client '1234abcd'
      client.oauth_authorize {service_id: '1234567890987', app_id: 'ERROR'}, (response) ->
        assert.equal response.is_success(), false
        assert.equal response.status_code, 403
        done()
    after ->
      nock.cleanAll()


  describe 'The oauth_authrep method', ->
    it 'should throw an exception if oauth_authrep called without :app_id', ->
      client = new Client()
      assert.throws (() -> client.oauth_authrep({}, () ->)), 'missing app_id'

    it 'should call the callback with a 200 response if app_id was ok', (done) ->
      nock('https://su1.3scale.net')
        .get('/transactions/oauth_authrep.xml')
        .query({
          service_id: 1234567890987,
          app_id: "foo",
          "usage[hits]":1,
          provider_key: "1234abcd"
        }) 
        .reply(200, '<status><authorized>true</authorized><plan>Basic</plan></status>')

      client = new Client '1234abcd'
      client.oauth_authrep { service_id: '1234567890987', app_id: 'foo',usage: { hits: 1 }}, (response) ->
        assert.equal response.is_success(), true
        assert.equal response.status_code, 200
        done()

    it 'should call the callback with a error response if app_id was wrong', (done) ->
      nock('https://su1.3scale.net')
        .get('/transactions/oauth_authrep.xml')
        .query({
          service_id: 1234567890987,
          app_id: "ERROR",
          "usage[hits]":1,
          provider_key: "1234abcd"
        }) 
        .reply(403, '<error code="application_not_found">application with id="ERROR" was not found</error>')

      client = new Client '1234abcd'
      client.oauth_authrep {service_id: '1234567890987', app_id: 'ERROR'}, (response) ->
        assert.equal response.is_success(), false
        assert.equal response.status_code, 403
        done()

    after ->
      nock.cleanAll()


  describe 'Request headers in authrep calls', ->
    it 'should throw an exception if authrep called without :app_id', ->
      client = new Client()
      assert.throws (() -> client.authrep({}, () ->)), 'missing app_id'

    it 'should include the Host and X-3scale-User-Agent headers', (done) ->
      opts =
        reqheaders:
          'Host': 'su1.3scale.net'
          'X-3scale-User-Agent': 'plugin-node-v' + require('../package.json').version

      match = nock('https://su1.3scale.net', opts)
        .get('/transactions/authorize.xml?service_id=1234567890987&app_id=foo&provider_key=1234abcd')
        .reply(200, '<status><authorized>true</authorized><plan>Basic</plan></status>')

      client = new Client '1234abcd'
      client.authorize { service_id: '1234567890987', app_id: 'foo' }, (response) ->
        assert match.isDone()
        done()
    after ->
      nock.cleanAll()


  describe 'Request headers in authrep_with_user_key calls', ->
    it 'should throw an exception if is called without :user_key', ->
      client = new Client()
      assert.throws (() -> client.authrep_with_user_key({}, ()->)), 'missing user_key'

    after ->
      nock.cleanAll()


  describe 'The report method', ->
    it 'should give a success response with the correct params with provider_key', (done) ->
      nock('https://su1.3scale.net')
        .post('/transactions.xml')
        .reply(202)

      client = new Client '1234abcd'
      client.report report_test, (response) ->
        assert response.is_success()
        done()

    it 'should give a success response with the correct params with service_token', (done) ->
      nock('https://su1.3scale.net')
        .post('/transactions.xml')
        .reply(202)

      client = new Client 
      client.report report_test_service_token, (response) ->
        assert response.is_success()
        done()

    after ->
      nock.cleanAll()

  describe 'Request headers in report calls', ->
    it 'should include the Host and X-3scale-User-Agent headers', (done) ->
      opts =
        reqheaders:
          'Host': 'su1.3scale.net'
          'X-3scale-User-Agent': 'plugin-node-v' + require('../package.json').version

      match = nock('https://su1.3scale.net', opts)
        .post('/transactions.xml')
        .reply(202)

      client = new Client '1234abcd'
      client.report report_test, (response) ->
        assert match.isDone()
        done()

    after ->
      nock.cleanAll()

