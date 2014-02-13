jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-overview-wizard-step')) return;

  // Show the map at the full-panel size
  $('#lmap').css('height', '690px');
  $('#_GMapContainer').css('height', '690px');
  $('#trip_map').show();

  // Show the start & end pins and ensure proper zoom/pan
  // See if we can find this existing marker

  ['start', 'stop'].forEach(function (markerName) {
    var marker = findMarkerById(markerName);
    addMarkerToMap(marker, true);
  });

  refreshMarkers();
  setMapToBounds();

  // Do this last
  invalidateMap();

  var leftResults = $('#left-results');

  $('#left-description').addClass('hidden');
  leftResults.removeClass('hidden');

  var trip = NewTrip.read()

  leftResults.find('.from')   .html(trip.from_place);
  leftResults.find('.to')     .html(trip.to_place);
  leftResults.find('.date')   .html(trip.trip_date);
  leftResults.find('.time')   .html(trip.trip_time);
  leftResults.find('.return') .html(trip.return_trip_time);

  if (trip.trip_purpose) leftResults.find('.reason').html(trip.trip_purpose.name);
  if (!trip.return_trip_time) $('.return').prev('h5').hide();
  if (trip.arrive_depart === 'Arriving By') $('.time').prev('h5').text('Arrival Time');

  //rename the Next Step button to say Plan my Trip
  $('.next-step-btn h1').html('Plan my Trip');

  $('.edit-trip-btn').removeClass('hidden');
  $.fn.datepicker.Calendar.hide();

  // tripformView.nextButton.off('click', tripformView.nextBtnHandler);
  // tripformView.nextButton.on('click', tripformView.submitButtonhandler);

  $('.js-trip-wizard-form').on('submit', function (e) {
    e.stopPropagation(); e.preventDefault();
    var $form = $(e.target);

    // clean up the data
    var trip_data = NewTrip.read();
    delete trip_data.default_return_trip_time;

    // this is the final step. Instead of POSTing the form, let's get
    // the trip object from localStorage and post all of the params from that.
    // this essentially acts the 'build' step.
    jQuery.ajax($form.attr('action'), {
      data: { trip_proxy: trip_data },
      type: 'POST',
      error: function (xhr, status, error) {
        NewTrip.showError(error);
      },
      complete: function (xhr, status) {
        if (status != 'error')
          NewTrip.stepCompleteHandler(e, xhr);
      }
    });
  });
});
