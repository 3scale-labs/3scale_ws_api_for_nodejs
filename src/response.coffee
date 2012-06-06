class Response
	constructor:() ->
		@error_message = null
		@error_code = null
	
	success: () ->
		@error_code = null
		@error_message = null
	
	error: (message, code = null) ->
		@error_code = code
		@error_message = message
	
	is_success: () ->
		((@error_code == null) && (@error_message == null))
	

module.exports = exports = Response