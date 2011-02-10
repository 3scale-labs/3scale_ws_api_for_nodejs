var AuthorizeResponse, Client, Response, exports, http, parserxml, querystring;
var __indexOf = Array.prototype.indexOf || function(item) {
  for (var i = 0, l = this.length; i < l; i++) {
    if (this[i] === item) return i;
  }
  return -1;
};
http = require('http');
querystring = require('querystring');
parserxml = require('o3-fastxml');
Response = require('./response');
AuthorizeResponse = require('./authorize_response');
/*

*/
Client = (function() {
  function Client(provider_key, default_host) {
    if (default_host == null) {
      default_host = "su1.3scale.net";
    }
    if (provider_key == null) {
      throw "missing provider_key";
    }
    this.provider_key = provider_key;
    this.host = default_host;
  }
  Client.prototype.authorize = function(options, callback) {
    var query, request, result, threescale, url, _self;
    _self = this;
    result = null;
    if ((typeof options !== 'object') && (options.app_id === null)) {
      throw "missing app_id";
    }
    url = "/transactions/authorize.xml?";
    query = querystring.stringify(options);
    query += '&' + querystring.stringify({
      provider_key: this.provider_key
    });
    threescale = http.createClient(80, this.host);
    request = threescale.request("GET", "" + url + query, {
      host: this.host
    });
    request.end();
    return request.on('response', function(response) {
      var xml;
      response.setEncoding('utf8');
      xml = "";
      response.on('data', function(chunk) {
        return xml += chunk;
      });
      return response.on('end', function() {
        var _ref;
        if (response.statusCode === 200 || response.statusCode === 409) {
          return callback(_self._build_success_authorize_response(xml));
        } else if (_ref = response.statusCode, __indexOf.call([400, 401, 402, 403, 404, 405, 406, 407, 408], _ref) >= 0) {
          return callback(_self._build_error_response(xml));
        } else {
          throw "[Client::authorize] Server Error Code: " + response.statusCode;
        }
      });
    });
  };
  Client.prototype.report = function(trans, callback) {
    var query, request, threescale, url, _self;
    _self = this;
    if (trans == null) {
      throw "no transactions to report";
    }
    url = "/transactions.xml";
    query = querystring.stringify({
      transactions: trans,
      provider_key: this.provider_key
    });
    threescale = http.createClient(80, this.host);
    request = threescale.request("POST", "" + url, {
      "host": this.host,
      "Content-Type": "application/x-www-form-urlencoded",
      "Content-Length": query.length
    });
    request.write(query);
    request.end();
    return request.on('response', function(response) {
      var xml;
      xml = "";
      response.on("data", function(data) {
        return xml += data;
      });
      return response.on('end', function() {
        if (response.statusCode === 202) {
          response = new Response();
          response.success();
          return callback(response);
        } else if (response.statusCode === 403) {
          return callback(_self._build_error_response(xml));
        }
      });
    });
  };
  Client.prototype._build_success_authorize_response = function(xml) {
    var authorize, doc, plan, reason, response, usage_report, usage_reports, _fn, _i, _len;
    response = new AuthorizeResponse();
    doc = parserxml.parseFromString(xml);
    authorize = doc.documentElement.selectNodes('authorized')[0].nodeValue;
    plan = doc.documentElement.selectNodes('plan')[0].nodeValue;
    if (authorize === 'true') {
      response.success();
    } else {
      reason = doc.documentElement.selectNodes('reason')[0].nodeValue;
      response.error(reason);
    }
    usage_reports = doc.documentElement.selectNodes('usage_reports/usage_report');
    _fn = function(usage_report) {
      var report;
      report = {
        period: usage_report.getAttribute('period'),
        metric: usage_report.getAttribute('metric'),
        period_start: usage_report.selectNodes('period_start')[0].nodeValue,
        period_end: usage_report.selectNodes('period_end')[0].nodeValue,
        current_value: usage_report.selectNodes('current_value')[0].nodeValue,
        max_value: usage_report.selectNodes('max_value')[0].nodeValue
      };
      return response.add_usage_reports(report);
    };
    for (_i = 0, _len = usage_reports.length; _i < _len; _i++) {
      usage_report = usage_reports[_i];
      _fn(usage_report);
    }
    return response;
  };
  Client.prototype._build_error_response = function(xml) {
    var doc, error, response;
    response = new AuthorizeResponse();
    doc = parserxml.parseFromString(xml);
    error = doc.documentElement;
    response = new Response();
    response.error(error.nodeValue, error.getAttribute('code'));
    return response;
  };
  return Client;
})();
module.exports = exports = Client;