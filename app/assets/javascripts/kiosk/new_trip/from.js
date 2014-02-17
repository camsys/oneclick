jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-from-wizard-step')) return;

  // ***************
  // Currently hard-coding this in place -- synchrotron will be doing this in the future!!!!
  // ***************
  addrConfig.setCurrentMachineNameInField("machine1");

  var useCurrentLocationHandler = function() {
    // Show the google map and re-calculate size. Have to do removeClass('hidden') before reset to ensure
    // that leaflet code knows the size of the map, so it can calculate size correctly.
    // $('#trip_map').removeClass('hidden');
    resetMapView();

    // Synchrotron will have set the machine name, so we can get the machine address
    var item = JSON.parse(addrConfig.getCurrentMachineAddressInField());

    removeMatchingMarkers('start');

    // Create a marker to keep around, but don't display it on the map
    marker = create_or_update_marker('start', item.lat, item.lon, item.addr, getFormattedAddrForMarker(item.addr), 'startIcon');

    // Update the UI
    $('#from_place_selected_type').attr('value', item.type);
    $('#from_place_selected').attr('value', item.id);
    $('#trip_proxy_from_place').val(item.addr);
    $('#trip_proxy_use_current_location').val('yes');
    $('.js-trip-wizard-form').submit();
  }

  if ($('#trip_proxy_from_place').val() === '')
    $('.next-step-btn').addClass('stop');

  NewTrip.requirePresenceToContinue($('#trip_proxy_from_place'));
  restore_marker_from_local_storage('start');

  $('#current-location a#yes').on('click', useCurrentLocationHandler);
  $('#current-location a#no').on('click', function () { $('#trip_proxy_use_current_location').val('no') });
  setupPlacesSearchTypeahead('from', 'start');

  //FROM LABEL APPEAR
  $('input#trip_proxy_from_place').focus(function(){
      if (window.cocoa)
        window.cocoa.openKeyboard();
      $('#from_input').addClass('text-added');
  });
  $('input#trip_proxy_from_place').click(function(){
       if (window.cocoa)
        window.cocoa.openKeyboard();
  });
  $('input#trip_proxy_from_place').blur(function(){
    if($(this).val().length > 0){
      //do nothing
    } else {
      $('#from_input').removeClass('text-added');
    }
  });
});
