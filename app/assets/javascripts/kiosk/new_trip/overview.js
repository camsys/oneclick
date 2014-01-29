jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-overview-wizard-step')) return;

  var editTripButtonInit = function() {
    var tripButton = $('.edit-trip-btn');
    var leftResults = $('#left-results p.return');
    tripButton.removeClass('hidden');

    tripButton.off('click');

    tripButton.on('click', function() {
      $('*[data-index=1]').removeClass('hidden');
      //Unhide the return trip if it was hidden
      leftResults.show();
      leftResults.prev('h5').show();
      //update the large blue button to read Next Step once again
      $('.next-step-btn h1').html('Next Step');
      //hide the results and show the description
      $('#left-description').removeClass('hidden');
      $('#left-results, .edit-trip-btn').addClass('hidden');
      $('#left-description h4').html("Tell Us Where You're Starting");
      $('#left-description p').html("Will you be traveling from your current location? Tap \"yes\" or \"no\". If \"no\", you will be prompted to enter an address to travel from in the next step.");
      $('#lmap').css('height', '558px');
      $('#_GMapContainer').css('height', '558px');

      tripformView.indexCounter = 1;
      tripformView.nextButton.off('click', tripformView.submitButtonhandler);
      tripformView.nextButton.on('click', tripformView.nextBtnHandler);

      tripformView.formEle.trigger('indexChange');
    });
  };

  // Show the map at the full-panel size
  $('#lmap').css('height', '690px');
  $('#_GMapContainer').css('height', '690px');
  $('#trip_map').show();

  // Show the start & end pins and ensure proper zoom/pan
  // See if we can find this existing marker

  var marker = findMarkerById('start');
  addMarkerToMap(marker, true);
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
  leftResults.find('.reason') .html(trip.trip_purpose_id);

  //rename the Next Step button to say Plan my Trip
  $('.next-step-btn h1').html('Plan my Trip');

  //$('.edit-trip-btn').removeClass('hidden');
  editTripButtonInit();
  $.fn.datepicker.Calendar.hide();

  // tripformView.nextButton.off('click', tripformView.nextBtnHandler);
  // tripformView.nextButton.on('click', tripformView.submitButtonhandler);
});
