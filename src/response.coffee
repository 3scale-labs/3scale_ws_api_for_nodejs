class Response
	constructor:() ->
		@error_message = null
		@error_code = null
		@status_code = null

	success: (status_code) ->
		@error_code = null
		@error_message = null
		@status_code = status_code
    
	error: (status_code, message, code = null) ->
		@error_code = code
		@error_message = message
		@status_code = status_code

	is_success: () ->
		((@error_code == null) && (@error_message == null))


module.exports = exports = Response