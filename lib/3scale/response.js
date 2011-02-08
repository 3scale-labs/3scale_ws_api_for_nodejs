var Response, exports;
Response = (function() {
  function Response(error_code, error_message) {
    this.error_code = error_code;
    this.error_message = error_message;
    this.error_message = null;
    this.error_code = null;
  }
  Response.prototype.success = function() {
    this.error_code = null;
    return this.error_message = null;
  };
  Response.prototype.error = function(message, code) {
    if (code == null) {
      code = null;
    }
    this.error_code = code;
    return this.error_message = message;
  };
  Response.prototype.is_success = function() {
    return !((this.error_code != null) && (this.error_message != null));
  };
  return Response;
})();
module.exports = exports = Response;