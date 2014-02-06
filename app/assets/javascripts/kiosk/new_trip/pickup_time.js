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

  //TOGGLE THE ARRIVE/DEPART STATE
  $('#arrive-depart-toggle').on('click', function () {
    var timeSection = $('#trip-time');
    var timeLabel = timeSection.children('label').text();
    $('#trip_proxy_arrive_depart option:selected').removeAttr("selected");

    if (timeLabel === 'Departing at') {
      //change the label to arriving
      timeSection.children('label').html('Arriving at');
      $('#trip_proxy_arrive_depart').find('option[value="Arriving By"]').attr('selected',true);
      //change the dropdown selected state...
    } else {
      //change the label to departing
      timeSection.children('label').html('Departing at');
      $('#trip_proxy_arrive_depart').find('option[value="Departing At"]').attr('selected',true);
      //toggle the arriving/departing state
    }
  });

  $('#left-description h4').html("Tell Us What Time You'll Be Leaving");
  $('#left-description p').html("Choose the time you will be leaving from your starting location. The next hour or half-hour has already been selected for you. <br><br> Tap \"Next Step\" when you have selected the correct time to leave.");
});
