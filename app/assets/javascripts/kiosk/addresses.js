(function () {
  var _currentMachineNameInField = null;

  window.addrConfig = {
    setCurrentMachineNameInField: function (name) {
      _currentMachineNameInField = name;
    },

    getCurrentMachineAddressInField: function () {
      var response = $.ajax('/kiosk/locations/' + _currentMachineNameInField, {
        type: 'GET',
        async: false
      });

      return response.responseJSON;
    }
  }
})();
