vows = require 'vows'
assert = require 'assert'

AuthorizeResponse = require('../src/authorize_response')

usage_report_options = 
	metric: 'hits'
	period: 'month'
	current_value: 17344
	max_value: 20000
	period_start: '2010-08-01 00:00:00 +00:00'
	period_end: '2010-09-01 00:00:00 +00:00'

vows
  .describe("Basic test for the 3Scale::AuthorizeResponse")
  .addBatch
    'A authorize_response Should':
      topic: -> new AuthorizeResponse()
      'have a add_usage_report method': (authorize_response) ->
        assert.isFunction authorize_response.add_usage_reports

      'can push a new UsageReport': (authorize_response) ->
        assert.lengthOf authorize_response.usage_reports, 0
        authorize_response.add_usage_reports usage_report_options
        assert.lengthOf authorize_response.usage_reports, 1
		
  .export(module)
