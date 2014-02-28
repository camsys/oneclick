// this file is only included in development environment.

(function () {
  if (window.cocoa) return;

  window.cocoa = {
    openKeyboard: function () { console.log('openKeyboard'); },
    closeKeyboard: function () { console.log('closeKeyboard'); },
    closeTelWindow: function () { console.log('closeTelWindow'); },
    getTelNumber: function () { console.log('getTelNumber'); }
  }
})();
