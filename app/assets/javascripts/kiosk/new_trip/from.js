jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-from-wizard-step')) return;

  var useCurrentLocationHandler = function() {
    // Show the google map and re-calculate size. Have to do removeClass('hidden') before reset to ensure
    // that leaflet code knows the size of the map, so it can calculate size correctly.
    // $('#trip_map').removeClass('hidden');
    resetMapView();

    // ***************
    // Currently hard-coding this in place -- synchrotron will be doing this in the future!!!!
    // ***************
    addrConfig.setCurrentMachineNameInField("machine1");

    // Synchrotron will have set the machine name, so we can get the machine address
    var item = JSON.parse(addrConfig.getCurrentMachineAddressInField());

    removeMatchingMarkers('start');

    // Create a marker to keep around, but don't display it on the map
    marker = create_or_update_marker('start', item.lat, item.lon, item.addr, getFormattedAddrForMarker(item.addr), 'startIcon');

    // Update the UI
    $('#from_place_selected_type').attr('value', item.type);
    $('#from_place_selected').attr('value', item.id);
    $('#trip_proxy_from_place').val(item.addr);
    $('.js-trip-wizard-form').submit();
  }

  $('#current-location a#yes').on('click', useCurrentLocationHandler);
  setupPlacesSearchTypeahead('from', 'start');
});
