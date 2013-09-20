$.rails.allowAction = function(element) {
  var answer, callback, message;
  message = element.data("confirm");
  if (!message) {
    return true;
  }
  answer = false;
  callback = void 0;
  if ($.rails.fire(element, "confirm")) {
    bootbox.confirm(message, function() {
      var oldAllowAction;
      callback = $.rails.fire(element, "confirm:complete", [answer]);
      if (callback) {
        oldAllowAction = $.rails.allowAction;
        $.rails.allowAction = function() {
          return true;
        };
        element.trigger("click");
        return $.rails.allowAction = oldAllowAction;
      }
    });
  }
  return false;
};
