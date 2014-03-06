jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-purpose-wizard-step')) return;

  var nextButtonValidatePurpose = function () {
    //Enable the "Next Step" button when the user clicks on one of the list elements
    $('#purposepicker ul li').on('click', function () {
      $('.next-step-btn').removeClass('stop');
    });
  };

  $('.next-step-btn').addClass('stop');
  nextButtonValidatePurpose();

  $('#purposepicker ul li').on('click', function () {
    var purposeSelect = $(this)
      , purposeId = purposeSelect.attr('name');

    // Part 1
    if (purposeSelect.hasClass('selected')) {
      // if class already exists on THIS li
      // do nothing
    } else {
      $('#purposepicker ul li').removeClass('selected');
      purposeSelect.addClass('selected');
      $('#trip_proxy_trip_purpose_id').val(purposeId);
    }
  });

  var purpose = NewTrip.read().trip_purpose;
  if (purpose) $('#purposepicker ul li:contains('+ purpose.name +')').click();
});
