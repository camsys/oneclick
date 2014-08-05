jQuery(function($) {
    if (!$('.js-trip-wizard-form').hasClass('js-return-time-wizard-step')) return;

    var noReturnTripHandler = function() {
        // Register that we do not want a return trip
        $('#trip_proxy_is_round_trip').prop('checked', false);

        // Hide the "Return Trip" section on the trip summary
        $('#left-results p.return').hide();
        $('#left-results p.return').prev('h5').hide();

        $('.js-trip-wizard-form').submit();
    }

    console.log('return_time.js ' + NewTrip.read().outbound_trip_time)
    $('.js-trip-wizard-form').find('#trip_proxy_outbound_trip_time').val(NewTrip.read().outbound_trip_time);

    if (NewTrip.read().return_trip_time) {
        $('.js-trip-wizard-form').find('#trip_proxy_return_trip_time').val(NewTrip.read().return_trip_time);
    } else if (NewTrip.read().default_return_trip_time) {
        $('.js-trip-wizard-form').find('#trip_proxy_return_trip_time').val(NewTrip.read().default_return_trip_time);
    }

    if (NewTrip.read().return_trip_date) {
        $('.js-trip-wizard-form').find('#trip_proxy_return_trip_date').val(NewTrip.read().return_trip_date);
    } else if (NewTrip.read().default_return_trip_date) {
        $('.js-trip-wizard-form').find('#trip_proxy_return_trip_date').val(NewTrip.read().default_return_trip_date);
    }

    NewTrip.timepickerInit('#trip_proxy_return_trip_time', '#timepicker-two');
    setupDatePickerForKiosk('#trip_proxy_return_trip_date', new Date(NewTrip.read().default_return_trip_date));

    $('#return-trip a#no').on('click', noReturnTripHandler);

    $('#return-trip a#yes').on('click', function() {
        // Register that we * do * want a return trip
        $('#trip_proxy_is_round_trip').prop('checked', true);
    });
});