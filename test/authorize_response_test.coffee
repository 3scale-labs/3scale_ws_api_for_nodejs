assert = require 'assert'

AuthorizeResponse = require('../src/authorize_response')

usage_report_options =
  metric: 'hits'
  period: 'month'
  current_value: 17344
  max_value: 20000
  period_start: '2010-08-01 00:00:00 +00:00'
  period_end: '2010-09-01 00:00:00 +00:00'

describe 'Basic test for the 3Scale::AuthorizeResponse', ->
  describe 'an authorize_response', ->
    it 'should have a add_usage_report method', ->
      authorize_response = new AuthorizeResponse()
      assert.equal typeof authorize_response.add_usage_reports, 'function'

    it 'should be able to push a new UsageReport', ->
      authorize_response = new AuthorizeResponse()
      assert.equal authorize_response.usage_reports.length, 0
      authorize_response.add_usage_reports usage_report_options
      assert.equal authorize_response.usage_reports.length, 1

    it 'should have a set_plan method', ->
      authorize_response = new AuthorizeResponse()
      assert.equal typeof authorize_response.set_plan, 'function'

    it 'should be able to set a plan', ->
      authorize_response = new AuthorizeResponse()
      assert.equal authorize_response.plan, null
      plan = 'Ultimate'
      authorize_response.set_plan plan
      assert.equal authorize_response.plan, plan