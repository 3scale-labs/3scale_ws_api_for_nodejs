http = require 'http'
sys = require 'sys'
querystring = require 'querystring'
parserxml = require 'o3-fastxml'

Response = require './response'
AuthorizeResponse = require './authorize_response'

###
	Wrapper for 3scale Web Service Management API.
	The constructor requires at least two parameters
		app_id => Application id
		provider_key => Provider key
	
	Example:
	
		var Client = require("3scale").Client;
		client = new Client('05273bcb282d1d4faafffeb01e224db0ZZZ')
		client.authorize {app_id: '75165984', app_key: '3e05c797ef193fee452b1ddf19defa74'}, (response) ->
			sys.log sys.inspect response
		

###
class Client

	constructor: (provider_key, default_host = "su1.3scale.net") ->
		unless provider_key?
			throw "missing provider_key"
		@provider_key = provider_key
		@host = default_host
  
	authorize: (options, callback) ->
		_self = this
		result = null
		if (typeof options isnt 'object') && (options.app_id == null)
			throw "missing app_id"

		url = "/transactions/authorize.xml?"
		query = querystring.stringify options
		query += '&' + querystring.stringify {provider_key: @provider_key}

		threescale = http.createClient 80, @host
		request = threescale.request "GET", "#{url}#{query}", {host: @host}
		request.end()
		request.on 'response', (response) ->
			sys.log "Status Code: #{response.statusCode}"
			response.setEncoding 'utf8'
			xml = ""
			response.on 'data', (chunk) ->
				xml += chunk
			
			response.on 'end', () ->
				if response.statusCode == 200 || response.statusCode == 409
					callback _self._build_success_authorize_response xml
				else if response.statusCode in [400...409]
					callback _self._build_error_response xml
				else
					throw "[Client::authorize] Server Error Code: #{response.statusCode}"
			
		
	
	report: (trans) ->
		unless trans?
			throw "no transactions to report"

		url = "/transactions.xml"
		query = querystring.stringify {transactions: trans, provider_key: @provider_key}
		sys.log query
		
		obj = querystring.parse query
		sys.log sys.inspect obj
		
		threescale = http.createClient 80, @host
		request = threescale.request "POST", "#{url}", 
			{"host": @host, "Content-Type": "application/x-www-form-urlencoded", "Content-Length": query.length}
		request.write query
		request.end()
		request.on 'response', (response) ->
			sys.log sys.inspect response.client
			sys.log response.statusCode
		

	

# privates methods
	_build_success_authorize_response: (xml) ->
		response = new AuthorizeResponse()
		doc = parserxml.parseFromString xml
		authorize = doc.documentElement.selectNodes('authorized')[0].nodeValue
		plan = doc.documentElement.selectNodes('plan')[0].nodeValue
		if authorize is 'true'
			response.success()
		else
			reason = doc.documentElement.selectNodes('reason')[0].nodeValue
			response.error(reason)
		
		usage_reports = doc.documentElement.selectNodes('usage_reports/usage_report')
		for usage_report in usage_reports
			do (usage_report) ->
				report =
					period: usage_report.getAttribute 'period'
					metric: usage_report.getAttribute 'metric'
					period_start: usage_report.selectNodes('period_start')[0].nodeValue
					period_end: usage_report.selectNodes('period_end')[0].nodeValue
					current_value: usage_report.selectNodes('current_value')[0].nodeValue
					max_value: usage_report.selectNodes('max_value')[0].nodeValue
				response.add_usage_reports report
			
		response
	
	_build_error_response: (xml) ->
		response = new AuthorizeResponse()
		doc = parserxml.parseFromString xml
		error = doc.documentElement
		
		response = new Response()
		response.error error.nodeValue, error.getAttribute 'code'
		response
	

# Export the module
module.exports = exports = Client

# client = new Client('05273bcb282d1d4faafffeb01e224db0')
# client.authorize {app_id: '75165984', app_key: '3e05c797ef193fee452b1ddf19defa74'}, (response) ->
# 	sys.log sys.inspect response.error_code

# 
# trans = [
# 	{ "app_id": "75165984", "usage": {"hits": 1}},
# 	{ "app_id": "75165984", "usage": {"hits": 1000}}
# ]
# 
# t = {transactions: trans, provider_key: "05273bcb282d1d4faafffeb01e224db0"}
# 
# sys.puts querystring.stringify t
# client.report trans