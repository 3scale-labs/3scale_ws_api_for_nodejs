assert = require 'assert'

# set keys as environment variables for tests that
# run against the 3scale API or use dummy keys
provider_key = process.env.TEST_3SCALE_PROVIDER_KEY
application_key = process.env.TEST_3SCALE_APP_KEY
application_id = process.env.TEST_3SCALE_APP_ID
service_id = process.env.TEST_3SCALE_SERVICE_ID

trans = [
  { 'app_id': application_id, 'usage': { 'hits': 1 } },
  { 'app_id': application_id, 'usage': { 'hits': 1000 } }
]
report_test = {service_id: service_id, transactions: trans, provider_key: provider_key}

Client = require('../src/client')

describe 'Integration tests for the 3Scale::Client', ->
  describe 'The authorize method', ->
    it 'should call the callback with a successful response', (done) ->
      client = new Client provider_key
      client.authorize {service_id: service_id, app_key: application_key, app_id: application_id}, (response) ->
        assert response.is_success()
        assert.equal response.status_code, 200
        done()

    it 'should call the callback with a error response if app_id was wrong', (done) ->
      client = new Client provider_key
      client.authorize {service_id: service_id, app_key: application_key, app_id: 'ERROR'}, (response) ->
        assert.equal response.is_success(), false
        assert.equal response.status_code, 404
        done()

  describe 'The report method', ->
    it 'should give a success response with the correct params', (done) ->
      client = new Client provider_key
      client.report report_test, (response) ->
        assert response.is_success()
        assert.equal response.status_code, 202
        done()
