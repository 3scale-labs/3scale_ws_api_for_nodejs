var AuthorizeResponse, authorize_response_suite, usage_report_options;
require('./common');
AuthorizeResponse = require('./../lib/3scale/authorize_response');
usage_report_options = {
  metric: 'hits',
  period: 'month',
  current_value: 17344,
  max_value: 20000,
  period_start: '2010-08-01 00:00:00 +00:00',
  period_end: '2010-09-01 00:00:00 +00:00'
};
authorize_response_suite = vows.describe("Basic test for the 3Scale::AuthorizeResponse");
authorize_response_suite.addBatch({
  'A authorize_response Should': {
    topic: function() {
      return new AuthorizeResponse();
    },
    'have a add_usage_report method': function(authorize_response) {
      return assert.isFunction(authorize_response.add_usage_reports);
    },
    'can push a new UsageReport': function(authorize_response) {
      assert.length(authorize_response.usage_reports, 0);
      authorize_response.add_usage_reports(usage_report_options);
      return assert.length(authorize_response.usage_reports, 1);
    }
  }
})["export"](module);