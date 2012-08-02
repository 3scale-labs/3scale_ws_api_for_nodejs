https = require 'https'
querystring = require 'querystring'
libxml = require 'libxmljs'

Response = require './response'
AuthorizeResponse = require './authorize_response'

###
  3Scale client API
  Parameter:
    provider_key {String} Required
    default_host {String} Optional
  Example:
    Client = require('3scale').Client
    client = new Client(provider_key, [default_host])
###
#
module.exports = class Client

  constructor: (provider_key, default_host = "su1.3scale.net") ->
    unless provider_key?
      throw "missing provider_key"
    @provider_key = provider_key
    @host = default_host


  ###
    Authorize a application

    Parameters:
      options is a Hash object with the following fields
        app_id Required
        app_key Required
        referrer Optional
        usage Optional
      callback {Function} Is the callback function that receives the Response object which includes `is_success`
              method to determine the status of the response

    Example:
      client.authorize {app_id: '75165984', app_key: '3e05c797ef193fee452b1ddf19defa74'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"

  ###
  authorize: (options, callback) ->
    _self = this
    result = null
    if (typeof options isnt 'object') && (options.app_id == null)
      throw "missing app_id"

    url = "/transactions/authorize.xml?"
    query = querystring.stringify options
    query += '&' + querystring.stringify {provider_key: @provider_key}

    req_opts = 
      host:   @host
      port:   443
      path:   url + query
      method: 'GET'
    request = https.request req_opts, (response) ->
      response.setEncoding 'utf8'
      xml = ""
      response.on 'data', (chunk) ->
        xml += chunk

      response.on 'end', ->
        if response.statusCode == 200 || response.statusCode == 409
          callback _self._build_success_authorize_response xml
        else if response.statusCode in [400...409]
          callback _self._build_error_response xml
        else
          throw "[Client::authorize] Server Error Code: #{response.statusCode}"
    request.end()




  ###
    Report transaction(s).

    Parameters:
      trans {Array} each array element contain information of a transaction. That information is in a Hash in the form
      {
        app_id {String} Required
        usage {Hash} Required
        timestamp {String} any string parseable by the Data object
      }
      callback {Function} Function that recive the Response object which include a `is_success` method. Required

    Example:
      trans = [
        { "app_id": "abc123", "usage": {"hits": 1}},
        { "app_id": "abc123", "usage": {"hits": 1000}}
      ]

      client.report trans, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"


  ###
  report: (trans, callback) ->
    _self = this
    unless trans?
      throw "no transactions to report"

    url = "/transactions.xml"
    query = querystring.stringify {transactions: trans, provider_key: @provider_key}

    req_opts = 
      host:    @host
      port:    443
      path:    url
      method:  'POST'
      headers: {"host": @host, "Content-Type": "application/x-www-form-urlencoded", "Content-Length": query.length}
    request = https.request req_opts, (response) ->
      xml = ""
      response.on "data", (data) ->
        xml += data

      response.on 'end', () ->
        if response.statusCode == 202
          response = new Response()
          response.success()
          callback response
        else if response.statusCode == 403
          callback _self._build_error_response xml
    request.write query
    request.end()


  # privates methods
  _build_success_authorize_response: (xml) ->
    response = new AuthorizeResponse()
    doc = libxml.parseXml xml
    authorize = doc.get('//authorized').text()
    plan = doc.get('//plan').text()
    
    if authorize is 'true'
      response.success()
    else
      reason = doc.get('//reason').text()
      response.error(reason)

    usage_reports = doc.get '//usage_reports'

    for index, usage_report of usage_reports.childNodes()
      do (usage_report) ->
        report =
          period: usage_report.attr('period').value()
          metric: usage_report.attr('metric').value()
          period_start: usage_report.get('period_start').text()
          period_end: usage_report.get('period_end').text()
          current_value: usage_report.get('current_value').text()
          max_value: usage_report.get('max_value').text()
        response.add_usage_reports report
    
    response

  _build_error_response: (xml) ->
    response = new AuthorizeResponse()
    doc = libxml.parseXml xml
    error = doc.get '/error'

    response = new Response()
    response.error error.text(), error.attr('code').value()
    response
