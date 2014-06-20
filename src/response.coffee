class Response
	constructor:() ->
		@error_message = null
		@error_code = null
		@plan = null
		@key = null
		@authorized = false
	
	success: () ->
		@error_code = null
		@error_message = null
		@authorized = true
	
	error: (message, code = null) ->
		@error_code = code
		@error_message = message
		@authorized = false
	
	set_plan: (plan) ->
		@plan = plan

	set_key: (key) ->
		@key = key

	is_success: () ->
		((@error_code == null) && (@error_message == null))
	

module.exports = exports = Response
