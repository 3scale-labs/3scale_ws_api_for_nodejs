assert = require 'assert'
nock   = require 'nock'

Client = require('../src/client')

describe 'Usage report tests for 3Scale::Client', ->
  it 'should parse the response of the Authorize call', (done) ->
    xml_body = "<status>\
                  <authorized>true</authorized>\
                  <plan>Ultimate</plan>\
                  <usage_reports>\
                    <usage_report metric=\"hits\" period=\"day\" exceeded=\"false\">\
                      <period_start>2010-04-26 00:00:00 +0000</period_start>\
                      <period_end>2010-04-27 00:00:00 +0000</period_end>\
                      <current_value>10002</current_value>\
                      <max_value>50000</max_value>\
                    </usage_report>\
                  </usage_reports>\
                </status>"

    nock('https://su1.3scale.net')
      .get('/transactions/authorize.xml?app_id=foo&provider_key=1234abcd')
      .reply(200, xml_body, { 'Content-Type': 'application/xml' })

    client = new Client '1234abcd'
    client.authorize { app_id: 'foo' }, (response) ->
      assert.equal response.is_success(), true
      assert.equal response.status_code, 200
      assert.equal response.plan, 'Ultimate'
      assert.equal response.usage_reports[0].metric, 'hits'
      assert.equal response.usage_reports[0].period, 'day'
      assert.equal response.usage_reports[0].period_start, '2010-04-26 00:00:00 +0000'
      assert.equal response.usage_reports[0].period_end, '2010-04-27 00:00:00 +0000'
      assert.equal response.usage_reports[0].current_value, '10002'
      assert.equal response.usage_reports[0].max_value, '50000'
      done()
      
  it 'should parse the response of the Authorize call, when limit is exceeded', (done) ->
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
      assert.equal response.status_code, 409
      assert.equal response.error_message, 'usage limits are exceeded'
      assert.equal response.plan, 'Ultimate'
      assert.equal response.usage_reports[0].metric, 'hits'
      assert.equal response.usage_reports[0].period, 'day'
      assert.equal response.usage_reports[0].period_start, '2010-04-26 00:00:00 +0000'
      assert.equal response.usage_reports[0].period_end, '2010-04-27 00:00:00 +0000'
      assert.equal response.usage_reports[0].current_value, '50002'
      assert.equal response.usage_reports[0].max_value, '50000'
      done()

  it 'should parse the response of the Authorize call with eternity limits', (done) ->
    xml_body = "<status>\
                  <authorized>false</authorized>\
                  <reason>usage limits are exceeded</reason>\
                  <plan>Ultimate</plan>\
                  <usage_reports>\
                    <usage_report metric=\"hits\" period=\"eternity\" exceeded=\"true\">\
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
      assert.equal response.status_code, 409
      assert.equal response.error_message, 'usage limits are exceeded'
      assert.equal response.plan, 'Ultimate'
      assert.equal response.usage_reports[0].metric, 'hits'
      assert.equal response.usage_reports[0].period, 'eternity'
      assert.equal response.usage_reports[0].period_start, undefined
      assert.equal response.usage_reports[0].period_end, undefined
      assert.equal response.usage_reports[0].current_value, '50002'
      assert.equal response.usage_reports[0].max_value, '50000'
      done()

  it 'should parse the response of the Authorize call with multiple usage_report entries', (done) ->
    xml_body = "<status>\
                  <authorized>true</authorized>\
                  <plan>Ultimate</plan>\
                  <usage_reports>\
                    <usage_report metric=\"hits\" period=\"day\" exceeded=\"false\">\
                      <period_start>2010-04-26 00:00:00 +0000</period_start>\
                      <period_end>2010-04-27 00:00:00 +0000</period_end>\
                      <current_value>10002</current_value>\
                      <max_value>50000</max_value>\
                    </usage_report>\
                    <usage_report metric=\"misses\" period=\"day\" exceeded=\"false\">\
                      <period_start>2010-04-26 00:00:00 +0000</period_start>\
                      <period_end>2010-04-27 00:00:00 +0000</period_end>\
                      <current_value>12</current_value>\
                      <max_value>50000</max_value>\
                    </usage_report>\
                  </usage_reports>\
                </status>"

    nock('https://su1.3scale.net')
    .get('/transactions/authorize.xml?app_id=foo&provider_key=1234abcd')
    .reply(200, xml_body, { 'Content-Type': 'application/xml' })

    client = new Client '1234abcd'
    client.authorize { app_id: 'foo' }, (response) ->
      assert.equal response.is_success(), true
      assert.equal response.status_code, 200
      assert.equal response.plan, 'Ultimate'
      
      assert.equal response.usage_reports[0].metric, 'hits'
      assert.equal response.usage_reports[0].period, 'day'
      assert.equal response.usage_reports[0].period_start, '2010-04-26 00:00:00 +0000'
      assert.equal response.usage_reports[0].period_end, '2010-04-27 00:00:00 +0000'
      assert.equal response.usage_reports[0].current_value, '10002'
      assert.equal response.usage_reports[0].max_value, '50000'
      
      assert.equal response.usage_reports[1].metric, 'misses'
      assert.equal response.usage_reports[1].period, 'day'
      assert.equal response.usage_reports[1].period_start, '2010-04-26 00:00:00 +0000'
      assert.equal response.usage_reports[1].period_end, '2010-04-27 00:00:00 +0000'
      assert.equal response.usage_reports[1].current_value, '12'
      assert.equal response.usage_reports[1].max_value, '50000'
      
      done()