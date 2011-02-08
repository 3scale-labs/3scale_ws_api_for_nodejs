var AuthorizeResponse, Response, exports;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
Response = require('./response');
AuthorizeResponse = (function() {
  var UsageReport;
  __extends(AuthorizeResponse, Response);
  UsageReport = (function() {
    function UsageReport(options) {
      this.metric = options.metric;
      this.period = options.period;
      this.current_value = options.current_value;
      this.max_value = options.max_value;
      this.period_start = options.period_start;
      this.period_end = options.period_end;
    }
    UsageReport.prototype.period_start = function() {};
    UsageReport.prototype.period_end = function() {};
    UsageReport.prototype.is_exceeded = function() {
      return this.current_value > this.max_value;
    };
    return UsageReport;
  })();
  function AuthorizeResponse(usage_reports) {
    this.usage_reports = usage_reports;
    this.usage_reports = [];
  }
  AuthorizeResponse.prototype.add_usage_reports = function(options) {
    return this.usage_reports.push(new UsageReport(options));
  };
  return AuthorizeResponse;
})();
module.exports = exports = AuthorizeResponse;