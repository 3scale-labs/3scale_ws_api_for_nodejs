https       = require 'https'
querystring = require 'qs'
xml2js      = require 'xml2js'
Promise     = require('es6-promise').Promise
VERSION     = require('../package.json').version

Response          = require './response'
AuthorizeResponse = require './authorize_response'

parser = new xml2js.Parser
  explicitArray: false
  mergeAttrs: true
  explicitAttrs: true
  charkey: 'text'

###
  3Scale client API
  Parameter: 
    provider_key {String} and service_token {String}: at least one of them is Required. On prem-instance use service_token (provider_key is deprecated, but the code will allow to use provider_key to avoid a breaking change). 
    default_host {String} Optional
    default_port {number} Optional
  Example:
    Client = require('3scale').Client
    client = new Client(provider_key, options)
    or
    client = new Client(null, options)
###


module.exports = class Client
  DEFAULT_HEADERS: { "X-3scale-User-Agent": "plugin-node-v#{VERSION}" }


  constructor: (provider_key, options) ->
    @provider_key = provider_key
    @options = options || {}
    @service_token = options.service_token
    @host = options.host || "su1.3scale.net"
    @port = options.port || 443

    unless @provider_key? and @service_token?
      throw new Error("missing provider_key or service_token")


  ###
    Authorize a application

    Parameters:
      options is a Hash object with the following fields
        app_id Required
        service_id Required (from November 2016)
        app_key Optional 
        referrer Optional
        usage Optional
      callback {Function} Is the callback function that receives the Response object which includes `is_success`
              method to determine the status of the response

    Example:
      client.authorize {service_id: '1234567890987', app_id: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"

  ###
  authorize: (options, callback) ->
    _self = this
    result = null

    if (typeof options isnt 'object') || (options.app_id is undefined) 
      throw "missing app_id"

    url = "/transactions/authorize.xml?"
    query = querystring.stringify options

    if @service_token
      query += '&' + querystring.stringify {service_token: @service_token} 
    else
      query += '&' + querystring.stringify {provider_key: @provider_key} 

    req_opts =
      host:   @host
      port:   @port
      path:   url + query
      method: 'GET'
      headers: @DEFAULT_HEADERS

    request = https.request req_opts, (response) ->
      response.setEncoding 'utf8'
      xml = ""
      response.on 'data', (chunk) ->
        xml += chunk

      response.on 'end', ->
        if response.statusCode == 200 || response.statusCode == 409
          _self._build_success_authorize_response(response.statusCode, xml, callback)
        else if response.statusCode in [400...409]
          _self._build_error_response(response.statusCode, xml, callback)
        else
          throw "[Client::authorize] Server Error Code: #{response.statusCode}"
    request.end()

  ###
    OAuthorize an Application
    Parameters:
      options is a Hash object with the following fields
        app_id Required
        service_id Required (from November 2016)
      callback {Function} Is the callback function that receives the Response object which includes `is_success`
              method to determine the status of the response

    Example:
      client.oauth_authorize {service_id: '1234567890987', app_id: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"

  ###
  oauth_authorize: (options, callback) ->
    _self = this
    if (typeof options isnt 'object')|| (options.app_id is undefined)
      throw "missing app_id"

    url = "/transactions/oauth_authorize.xml?"
    query = querystring.stringify options

    if @service_token 
      query += '&' + querystring.stringify {service_token: @service_token} 
    else
      query += '&' + querystring.stringify {provider_key: @provider_key} 

    req_opts =
      host:   @host
      port:   @port
      path:   url + query
      method: 'GET'
      headers: @DEFAULT_HEADERS

    request = https.request req_opts, (response) ->
      response.setEncoding 'utf8'
      xml = ""
      response.on 'data', (chunk) ->
        xml += chunk

      response.on 'end', ->
        if response.statusCode == 200 || response.statusCode == 409
          _self._build_success_authorize_response(response.statusCode, xml, callback)
        else if response.statusCode in [400...409]
          _self._build_error_response(response.statusCode, xml, callback)
        else
          throw "[Client::oauth_authorize] Server Error Code: #{response.statusCode}"
    request.end()

  ###
    Authorize with user_key
    Parameters:
      options is a Hash object with the following fields
        user_key Required
        service_id Required (from November 2016)
      callback {Function} Is the callback function that receives the Response object which includes `is_success`
              method to determine the status of the response

    Example:
      client.authorize_with_user_key {service_id: '1234567890987', user_key: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"

  ###
  authorize_with_user_key: (options, callback) ->
    _self = this

    if (typeof options isnt 'object') || (options.user_key is undefined)
      throw "missing user_key"

    url = "/transactions/authorize.xml?"
    query = querystring.stringify options

    if @service_token
      query += '&' + querystring.stringify {service_token: @service_token} 
    else
      query += '&' + querystring.stringify {provider_key: @provider_key} 

    req_opts =
      host:   @host
      port:   @port
      path:   url + query
      method: 'GET'
      headers: @DEFAULT_HEADERS

    request = https.request req_opts, (response) ->
      response.setEncoding 'utf8'
      xml = ""
      response.on 'data', (chunk) ->
        xml += chunk

      response.on 'end', ->
        if response.statusCode == 200 || response.statusCode == 409
          _self._build_success_authorize_response(response.statusCode, xml, callback)
        else if response.statusCode in [400...409]
          _self._build_error_response(response.statusCode, xml, callback)
        else
          throw "[Client::authorize_with_user_key] Server Error Code: #{response.statusCode}"
    request.end()

  ###
    Authorize and Report in single call
      options is a Hash object with the following fields
        app_id Required
        service_id Required (from November 2016)
        app_key, user_id, object, usage, no-body
      callback {Function} Is the callback function that receives the Response object which includes `is_success`
              method to determine the status of the response

    Example:
      client.authrep {service_id: '1234567890987', app_id: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"

  ###
  authrep: (options, callback) ->
    _self = this
    if (typeof options isnt 'object') || (options.app_id is undefined)
      throw "missing app_id"
    options.usage || options.usage = { hits: 1 }

    url = "/transactions/authrep.xml?"
    query = querystring.stringify options

    if @service_token
      query += '&' + querystring.stringify {service_token: @service_token} 
    else
      query += '&' + querystring.stringify {provider_key: @provider_key} 


    req_opts =
      host:   @host
      port:   @port
      path:   url + query
      method: 'GET'
      headers: @DEFAULT_HEADERS

    request = https.request req_opts, (response) ->
      response.setEncoding 'utf8'
      xml = ""
      response.on 'data', (chunk) ->
        xml += chunk

      response.on 'end', ->
        if response.statusCode == 200 || response.statusCode == 409
          _self._build_success_authorize_response(response.statusCode, xml, callback)
        else if response.statusCode in [400...409]
          _self._build_error_response(response.statusCode, xml, callback)
        else
          throw "[Client::authrep] Server Error Code: #{response.statusCode}"
    request.end()

  ###
    Authorize and Report with :user_key
      options is a Hash object with the following fields
        user_key Required
        service_id Required (from November 2016)
      callback {Function} Is the callback function that receives the Response object which includes `is_success`
              method to determine the status of the response

    Example:
      client.authrep_with_user_key {service_id: '1234567890987', user_key: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"
  ###
  authrep_with_user_key: (options, callback) ->
    _self = this
    if (typeof options isnt 'object') || (options.user_key is undefined)
      throw "missing user_key"

    url = "/transactions/authrep.xml?"
    query = querystring.stringify options

    if @service_token
      query += '&' + querystring.stringify {service_token: @service_token} 
    else
      query += '&' + querystring.stringify {provider_key: @provider_key} 


    req_opts =
      host:   @host
      port:   @port
      path:   url + query
      method: 'GET'
      headers: @DEFAULT_HEADERS

    request = https.request req_opts, (response) ->
      response.setEncoding 'utf8'
      xml = ""
      response.on 'data', (chunk) ->
        xml += chunk

      response.on 'end', ->
        if response.statusCode == 200 || response.statusCode == 409
          _self._build_success_authorize_response(response.statusCode, xml, callback)
        else if response.statusCode in [400...409]
          _self._build_error_response(response.statusCode, xml, callback)
        else
          throw "[Client::authrep_with_user_key] Server Error Code: #{response.statusCode}"
    request.end()

  ###
    Report transaction(s).

    Parameters:
      service_id {String} Required (from November 2016)
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

      client.report "your service id", trans, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"


  ###
  report: (service_id, trans, callback) ->
    _self = this

    if (typeof service_id is 'object') and (typeof trans is 'function')
      callback = trans
      trans = service_id
      service_id = undefined

    unless trans?
      throw new Error("no transactions to report")

    url = "/transactions.xml"

    if @service_token
      params = {transactions: trans, service_token: @service_token} 
    else
      params = {transactions: trans, provider_key: @provider_key}
    
    params.service_id = service_id if service_id
    query = querystring.stringify(params).replace(/\[/g, "%5B").replace(/\]/g, "%5D")

    req_opts =
      host:    @host
      port:    @port
      path:    url
      method:  'POST'
      headers:
        "host": @host
        "Content-Type": "application/x-www-form-urlencoded"
        "Content-Length": query.length

    req_opts.headers[key] = value for key, value of @DEFAULT_HEADERS

    request = https.request req_opts, (response) ->
      xml = ""
      response.on "data", (data) ->
        xml += data

      response.on 'end', () ->
        if response.statusCode == 202
          _response = new Response()
          _response.success(response.statusCode)
          callback _response
        else if response.statusCode == 403
          _self._build_error_response(response.statusCode, xml, callback)
    request.write query
    request.end()


  # private methods
  _parseXML: (xml) ->
    return new Promise (resolve, reject) ->
      parser.parseString xml, (err, res) ->
        if err 
          reject(err)
        else
          resolve(res)

  _build_success_authorize_response: (status_code, xml, callback) ->
    @_parseXML(xml)
    .catch (err) -> throw err
    .then (doc) ->
      response = new AuthorizeResponse()
      authorize = doc.status.authorized
      plan = doc.status.plan
      usage_reports = doc.status.usage_reports

      if authorize is 'true'
        response.success(status_code)
      else
        reason = doc.status.reason
        response.error(status_code, reason)

      response.set_plan plan
      
      if usage_reports

        usage_reports = if usage_reports.usage_report.length? then usage_reports.usage_report else [usage_reports.usage_report]

        for index, usage_report of usage_reports
          do (usage_report) ->
            report =
              period: usage_report.period
              metric: usage_report.metric
              current_value: usage_report.current_value
              max_value: usage_report.max_value
            
            if report.period isnt 'eternity'
              report.period_start = usage_report.period_start
              report.period_end   = usage_report.period_end

            response.add_usage_reports report

      callback(response)

  _build_error_response: (status_code, xml, callback) ->
    @_parseXML(xml)
    .catch (err) -> throw err
    .then (doc) ->
      error = doc.error
      response = new Response()
      response.error status_code, error.text, error.code
      callback(response)
