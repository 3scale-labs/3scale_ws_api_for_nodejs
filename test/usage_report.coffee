assert = require 'assert'
nock   = require 'nock'

# set keys as environment variables for tests that
# run against the 3scale API or use dummy keys
provider_key = process.env.TEST_3SCALE_PROVIDER_KEY
application_key = process.env.TEST_3SCALE_APP_KEY
application_id = process.env.TEST_3SCALE_APP_ID

Client = require('../src/client')

describe 'Usage report tests for 3Scale::Client', ->
  it 'should successfully parse the response of the Authorize call', (done) ->
    xml_body = "<status>\
                  <authorized>false</authorized>\
                  <reason>usage limits are exceeded</reason>\
                  <plan>Ultimate</plan>\
                  <usage_reports>\
                    <usage_report metric=\"hits\" period=\"day\" exceeded=\"true\">\
                      <period_start>2010-04-26 00:00:00 +0000</period_start>\
                      <period_end>2010-04-27 00:00:00 +0000</period_end>\
                      <current_value>50002</current_value>\
                      <max_value>50000</max_value>\
                    </usage_report>\
                  </usage_reports>\
                </status>"

    nock('https://su1.3scale.net')
      .get('/transactions/authorize.xml?app_id=foo&provider_key=1234abcd')
      .reply(409, xml_body, { 'Content-Type': 'application/xml' })

    client = new Client '1234abcd'
    client.authorize { app_id: 'foo' }, (response) ->
      assert.equal response.is_success(), false
      assert.equal response.error_message, 'usage limits are exceeded'
      assert.equal response.usage_reports[0].metric, 'hits'
      assert.equal response.usage_reports[0].period, 'day'
      assert.equal response.usage_reports[0].period_start, '2010-04-26 00:00:00 +0000'
      assert.equal response.usage_reports[0].period_end, '2010-04-27 00:00:00 +0000'
      assert.equal response.usage_reports[0].current_value, '50002'
      assert.equal response.usage_reports[0].max_value, '50000'
      done()