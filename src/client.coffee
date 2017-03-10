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
    provider_key {String} Required if you don't use service_token in the method. 
    Options: 
      host {String} Optional
      port {number} Optional
  
  Example:
    Client = require('3scale').Client
    
    client = new Client(provider_key, options)    //If you use your provider_key
    or 
    client = new Client(options)                  //If you use a service_token in the method
###


module.exports = class Client
  DEFAULT_HEADERS: { "X-3scale-User-Agent": "plugin-node-v#{VERSION}" }


  constructor: (provider_key, options) ->
    if typeof provider_key is 'object' and options is undefined
      opts = provider_key
    else
      @provider_key = provider_key
      console?.warn?('provider_key is deprecated in favor of service_token with service_id. The release of this client will default to use service_token')
      opts = options

    @host = opts?.host ? 'su1.3scale.net'
    @port = opts?.port ? 443

    


  ###
    Authorize an Application
    ------------------------

    Parameters:
      options is a Hash object with the following fields
        service_token Required if you didn't use provider_key to ceate the Client instance 
        app_id Required
        service_id Required (from November 2016)
        app_key Optional 
        referrer Optional
        usage Optional
      callback {Function} Is the callback function that receives the Response object which includes `is_success` method to determine the status of the response

    Example using provider_key:
      client.authorize {service_id: '1234567890987', app_id: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"

    Example using service_token:
      client.authorize {service_token: '12sdtsdr23454sdfsdf', service_id: '1234567890987', app_id: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"
  ###

  authorize: (options, callback) ->
    result = null

    this._verify_app_id_exists options 

    query = this._build_query_string options
    req_opts = this._prepare_request "/transactions/authorize.xml", query

    this._do_request_response req_opts, callback, "Client::authorize"
    


  ###
    OAuthorize an Application
    -------------------------

    Parameters:
      options is a Hash object with the following fields
        service_token Required if you didn't use provider_key to ceate the Client instance 
        app_id Required
        service_id Required (from November 2016)
      callback {Function} Is the callback function that receives the Response object which includes `is_success` method to determine the status of the response

    Example using provider_key:
      client.oauth_authorize {service_id: '1234567890987', app_id: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"

    Example using service_token:
      client.oauth_authorize {service_token: '12sdtsdr23454sdfsdf', service_id: '1234567890987', app_id: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"
  ###


  oauth_authorize: (options, callback) ->
    this._verify_app_id_exists options

    query = this._build_query_string options
    req_opts = this._prepare_request "/transactions/oauth_authorize.xml", query

    this._do_request_response req_opts, callback, "Client::oauth_authorize"


  ###
    Authorize with user_key
    -----------------------

    Parameters:
      options is a Hash object with the following fields
        service_token Required if you didn't use provider_key to ceate the Client instance
        user_key Required
        service_id Required (from November 2016)
      callback {Function} Is the callback function that receives the Response object which includes `is_success` method to determine the status of the response

    Example using provider_key:
      client.authorize_with_user_key {service_id: '1234567890987', user_key: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"

    Example using service_token:
      client.authorize_with_user_key {service_token: '12sdtsdr23454sdfsdf', service_id: '1234567890987', user_key: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"
  ###


  authorize_with_user_key: (options, callback) ->
    this._verify_user_key_exists options

    query = this._build_query_string options
    req_opts = this._prepare_request "/transactions/authorize.xml", query

    this._do_request_response req_opts, callback, "Client::authorize_with_user_key"
    


  ###
    Authorize and Report in a single call with app_id and app_key
    -------------------------------------------------------------
    
    Parameters:
      options is a Hash object with the following fields
        service_token Required if you didn't use provider_key to ceate the Client instance
        app_id Required
        service_id Required (from November 2016)
        app_key, user_id, object, usage, no-body
      callback {Function} Is the callback function that receives the Response object which includes `is_success` method to determine the status of the response

    Example using provider_key:
      client.authrep {service_id: '1234567890987', app_id: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"

    Example using service_token:
      client.authrep {service_token: '12sdtsdr23454sdfsdf', service_id: '1234567890987', app_id: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"
  ###

  authrep: (options, callback) ->
    this._verify_app_id_exists options

    this._ensure_hits_exist_in options

    query = this._build_query_string options
    req_opts = this._prepare_request "/transactions/authrep.xml", query

    this._do_request_response req_opts, callback, "Client::authrep"



  ###
    Authorize and Report in a single call with user_key
    ---------------------------------------------------
    
    Parameters:
      options is a Hash object with the following fields
        service_token Required if you didn't use provider_key to ceate the Client instance
        user_key Required
        service_id Required (from November 2016)
      callback {Function} Is the callback function that receives the Response object which includes `is_success` method to determine the status of the response

    Example using provider_key:
      client.authrep_with_user_key {service_id: '1234567890987', user_key: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"
  
    Example using service_token:
      client.authrep_with_user_key {service_token: '12sdtsdr23454sdfsdf', service_id: '1234567890987', user_key: 'ca5c5a49'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"
  ###

  authrep_with_user_key: (options, callback) ->
    this._verify_user_key_exists options

    this._ensure_hits_exist_in options

    query = this._build_query_string options
    req_opts = this._prepare_request "/transactions/authrep.xml", query

    this._do_request_response req_opts, callback, "Client::authrep_with_user_key"



  ###
    Authorize and Report in a single call with OAuth
    ------------------------------------------------
    
    Parameters:
      options is a Hash object with the following fields:
        service_token Required if you didn't use provider_key to ceate the Client instance
        app_id Required. app_id is your Client ID. 
        service_id Required (from November 2016)
      callback {Function} Is the callback function that receives the Response object which includes `is_success` method to determine the status of the response

    Example using provider_key:
      client.oauth_authrep {service_id: '1234567890987', app_id: '87654321'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"
  
    Example using service_token:
      client.authrep_oauth {service_token: '12sdtsdr23454sdfsdf', service_id: '1234567890987', app_id: '87654321'}, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"
  ###

  oauth_authrep: (options, callback) ->
    this._verify_app_id_exists options

    this._ensure_hits_exist_in options

    query = this._build_query_string options
    req_opts = this._prepare_request "/transactions/oauth_authrep.xml", query

    this._do_request_response req_opts, callback, "Client::oauth_authrep"



  ###
    Report transaction(s)
    ---------------------
    Parameters:
      service_id {String} Required (from November 2016)
      trans {Array} Each array element contain information of a transaction. That information is in a Hash in the form
        A) if you used provider_key to ceate the Client instance 
        {
          app_id {String} Required
          usage {Hash} Required
          timestamp {String} any string parseable by the Data object
        }
        B) if you didn't use provider_key to ceate the Client instance
        {
          service_token {String} Required
          app_id {String} Required
          usage {Hash} Required
          timestamp {String} any string parseable by the Data object
        }

      callback {Function} Function that recive the Response object which include a `is_success` method. Required

    
    Example using provider_key:
      trans = [
        { "app_id": "abc123", "usage": {"hits": 1}},
        { "app_id": "abc123", "usage": {"hits": 1000}}
      ]

      client.report "your service id", trans, (response) ->
        if response.is_success
          # All Ok
        else
         sys.puts "#{response.error_message} with code: #{response.error_code}"

    Example using service_token:
      trans = [
        { "service_token": "12sdtsdr23454sdfsdf", "app_id": "abc123", "usage": {"hits": 1}},
        { "service_token": "12sdtsdr23454sdfsdf", "app_id": "abc123", "usage": {"hits": 1000}}
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

    if trans.service_token
      params = {transactions: trans}
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

  ################################################################################################
  ################################################################################################
  ################################################################################################
  ################################################################################################
  ################################################################################################
  ################################################################################################

  # private methods

  _ensure_hits_exist_in: (options) ->
    options.usage || options.usage = { hits: 1 }

  _build_query_string: (options) ->
    if options.service_token
      query = querystring.stringify options
    else
      replacer = (key, value) ->
        if key == 'service_token'
          undefined
        else
          value
      query = querystring.stringify options, replacer   
      query += '&' + querystring.stringify {provider_key: @provider_key}
    return query

  _do_request_response: (req_opts, callback, error_message) ->
    _self = this
    request = https.request req_opts, (response) ->
      response.setEncoding 'utf8'
      xml = ""
      response.on 'data', (chunk) ->
        xml += chunk

      response.on 'end', ->
        if response.statusCode == 200 || response.statusCode == 409
          _self._build_success_authorize_response response.statusCode, xml, callback
        else if response.statusCode in [400...409]
          _self._build_error_response(response.statusCode, xml, callback)
        else
          throw "#{error_message} Server Error Code: #{response.statusCode}"
    request.end()


  _prepareRequestObject: (headers, method, host, port, path, query) ->
    req_opts =
      host:   host
      port:   port
      path:   path + "?" + query
      method: method
      headers: headers
    return req_opts

  ###
    Convenience method to build the req_opts we'll use throughout the Client class.
  ###
  _prepare_request: (path, query) ->
    return this._prepareRequestObject(@DEFAULT_HEADERS, 'GET', @host, @port, path, query)

  ###
   Grants options.app_id exists. 
   If param `options` is not an object or doesn't contain 'app_id' throws error
  ###
  _verify_app_id_exists: (options) ->
    if (typeof options isnt 'object') || (options.app_id is undefined) 
      throw "missing app_id"

  ###
   Grants options.user_key exists. 
   If param `options` is not an object or doesn't contain 'user_key' throws error
  ###
  _verify_user_key_exists: (options) ->
    if (typeof options isnt 'object') || (options.user_key is undefined)
      throw "missing user_key"


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
