jQuery(function($) {
    if (!$('.js-trip-wizard-form').hasClass('js-overview-wizard-step')) return;

    // Show the map at the full-panel size
    $('#lmap').css('height', '690px');
    $('#_GMapContainer').css('height', '690px');
    $('#trip_map').show();

    // Show the start & end pins and ensure proper zoom/pan
    // See if we can find this existing marker

    ['start', 'stop'].forEach(function(markerName) {
        var marker = CsMaps.lmap.findMarkerById(markerName);
        CsMaps.lmap.addMarkerToMap(marker, true);
    });

    CsMaps.lmap.refreshMarkers();
    CsMaps.lmap.setMapToBounds();

    // Do this last
    CsMaps.lmap.invalidateMap();

    var leftResults = $('#left-results');

    $('#left-description').addClass('hidden');
    leftResults.removeClass('hidden');

    var trip = NewTrip.read()

    leftResults.find('.from').html(trip.from_place);
    leftResults.find('.to').html(trip.to_place);
    leftResults.find('.date').html(trip.outbound_trip_date);
    leftResults.find('.time').html(trip.outbound_trip_time);
    leftResults.find('.return').html(trip.return_trip_time);

    if (trip.trip_purpose) leftResults.find('.reason').html(trip.trip_purpose_name);
    if (!trip.return_trip_time) $('.return').prev('h5').hide();
    if (trip.arrive_depart === 'Arriving By') $('.time').prev('h5').text('Arrival Time');

    //rename the Next Step button to say Plan my Trip
    $('.next-step-btn h1').html('Plan my Trip');

    $('.edit-trip-btn').removeClass('hidden');
    $.fn.datepicker.Calendar.hide();

    $('.js-trip-wizard-form').on('submit', function(e) {
        e.stopPropagation();
        e.preventDefault();
        var $form = $(e.target),
            trip_data = NewTrip.read();

        // clean up the data
        // default trip time is only used by the wizard. It does not end up getting stored.
        delete trip_data.default_return_trip_time;
        delete trip_data.default_return_trip_date;

        // same with whether or not the user chose to use the current location.
        // only the user's current location's data ends up getting stored.
        // we keep track of their choice so that the back button can behave properly during
        // the course of the wizard.
        delete trip_data.use_current_location;

        // also delete the translated purpose name
        delete trip_data.trip_purpose_name

        // this is the final step. Instead of POSTing the form, let's get
        // the trip object from localStorage and post all of the params from that.
        // this essentially acts the 'build' step.
        jQuery.ajax($form.attr('action'), {
            data: {
                trip_proxy: trip_data
            },
            type: 'POST',
            error: function(xhr, status, error) {
                NewTrip.showError(error);
            },
            complete: function(xhr, status) {
                if (status != 'error') NewTrip.stepCompleteHandler(e, xhr);
            }
        });
    });
});