class Response
	constructor:( @error_code, @error_message) ->
		@error_message = null
		@error_code = null
	
	success: () ->
		@error_code = null
		@error_message = null
	
	error: (message, code = null) ->
		@error_code = code
		@error_message = message
	
	is_success: () ->
		not (@error_code? && @error_message?)
	

module.exports = exports = Response