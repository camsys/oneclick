jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-pickup-time-wizard-step')) return;

  $('#trip-date')
    .datepicker()
    .on("dateChange", function(e) {
        $('#trip_proxy_trip_date').val(Date.format(e.date, "mm/dd/yyyy"));
    }).data('calendar')
      .setStartDate(new Date);

  NewTrip.timepickerInit('#trip_proxy_trip_time', '#timepicker-one');
  $('#trip-date').data('calendar').mbShow();

  $('.combobox').combobox({
    force_match: false
  });

  // Time Picker (outbound trip)
  // $.fn.datepicker.Calendar.hide();

  // Initialize time picker for outbound trip
  NewTrip.timepickerInit('#trip_proxy_trip_time', '#timepicker-one');

  $('#left-description h4').html("Tell Us What Time You'll Be Leaving");
  $('#left-description p').html("Choose the time you will be leaving from your starting location. The next hour or half-hour has already been selected for you. <br><br> Tap \"Next Step\" when you have selected the correct time to leave.");
});
