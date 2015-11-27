assert = require 'assert'
nock   = require 'nock'

# set keys as environment variables for tests that
# run against the 3scale API or use dummy keys
provider_key = process.env.TEST_3SCALE_PROVIDER_KEY
application_key = process.env.TEST_3SCALE_APP_KEY
application_id = process.env.TEST_3SCALE_APP_ID

trans = [
  { 'app_id': application_id, 'usage': { 'hits': 1 } },
  { 'app_id': application_id, 'usage': { 'hits': 1000 } }
]
report_test = {transactions: trans, provider_key: provider_key}

Client = require('../src/client')

describe 'Basic test for the 3Scale::Client', ->
  describe 'A client', ->
    it 'should throw an exception if init without provider_key', ->
      call = -> new Client()
      assert.throws call, 'missing provider_key'

    it 'should have an default host', ->
      client = new Client(123)
      assert.equal client.host, 'su1.3scale.net'

    it 'can change the default host', ->
      client = new Client(123, 'example.com')
      assert.equal client.host, 'example.com'

    it 'should have an authorize method', ->
      client = new Client(provider_key)
      assert.equal typeof client.authorize, 'function'

    it 'should throw an exception if authorize method is called without :app_id', ->
      client = new Client(provider_key)
      assert.throws (() -> client.authorize({}, () ->)), 'missing app_id'

    it 'should have an oauth_authorize method', ->
      client = new Client(provider_key)
      assert.equal typeof client.oauth_authorize, 'function'

    it 'should throw an exception if oauth_authorize method is called without :app_id', ->
      client = new Client(provider_key)
      assert.throws (() ->  client.oauth_authorize({}, () ->)), 'missing app_id'

    it 'should have an authorize_with_user_key method', ->
      client = new Client(provider_key)
      assert.equal typeof client.authorize_with_user_key, 'function'

    it 'should throw an exception if authorize_with_user_key is called without :user_key', ->
      client = new Client(provider_key)
      assert.throws (() -> client.authorize_with_user_key({}, () ->)), 'missing user_key'

    it 'should have an authrep method', ->
      client = new Client(provider_key)
      assert.equal typeof client.authrep, 'function'

    it 'should throw an exception if authrep called without :app_id', ->
      client = new Client(provider_key)
      assert.throws (() -> client.authrep({}, () ->)), 'missing app_id'

    it 'should have an authrep_with_user_key method', ->
      client = new Client(provider_key)
      assert.equal typeof client.authrep_with_user_key, 'function'

    it 'should throw an exception if authrep_with_user_key is called without :user_key', ->
      client = new Client(provider_key)
      assert.throws (() -> client.authrep_with_user_key({}, ()->)), 'missing user_key'

  describe 'The authorize method', ->
    it 'should call the callback with a successful response', (done) ->
      client = new Client provider_key
      client.authorize {app_key: application_key, app_id: application_id}, (response) ->
        assert response.is_success()
        done()

    it 'should call the callback with a error response if app_id was wrong', (done) ->
      client = new Client provider_key
      client.authorize {app_key: application_key, app_id: 'ERROR'}, (response) ->
        assert.equal response.is_success(), false
        done()

  describe 'The report method', ->
    it 'should give a success response with the correct params', (done) ->
      client = new Client provider_key
      client.report report_test, (response) ->
        assert response.is_success()
        done()

  describe 'Request headers in authrep calls', ->
    it 'should include the Host and X-3scale-User-Agent headers', (done) ->
      opts =
        reqheaders:
          'Host': 'su1.3scale.net'
          'X-3scale-User-Agent': 'plugin-node-v' + require('../package.json').version

      match = nock('https://su1.3scale.net', opts)
        .get('/transactions/authorize.xml?app_id=foo&provider_key=1234abcd')
        .reply(200, '<status><authorized>true</authorized><plan>Basic</plan></status>')

      client = new Client '1234abcd'
      client.authorize { app_id: 'foo' }, (response) ->
        assert match.isDone()
        done()

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
