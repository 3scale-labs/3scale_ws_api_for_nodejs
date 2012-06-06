Response = require './response'
class AuthorizeResponse extends Response

	class UsageReport
		constructor: (options) ->
			@metric = options.metric
			@period = options.period
			@current_value = options.current_value
			@max_value = options.max_value
			@period_start = options.period_start
			@period_end = options.period_end
		
		period_start: () ->
			# TODO: haz algo 
		
		period_end: () ->
			# TODO: haz algo 
		
		is_exceeded: () ->
			@current_value > @max_value
		

	constructor: (@usage_reports) ->
		@usage_reports = []
	

	add_usage_reports: (options) ->
		@usage_reports.push new UsageReport options
	

module.exports = exports = AuthorizeResponse