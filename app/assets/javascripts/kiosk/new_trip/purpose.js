jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-purpose-wizard-step')) return;

  var purposepickerSels = $('#purposepicker ul li');
  var nextButtonValidatePurpose = function() {
    // Enable the "Next Step" button when the user clicks on one of the list elements
    // purposepickerSels.on('click', function() {
    //   nextButton.removeClass('stop');
    // });
  };

  nextButtonValidatePurpose();
  $('#left-description h4').html("Tell Us Why You Are Making This Trip");
  $('#left-description p').html("Choose the option that best describes why you are making this trip. Providing this information helps us provide the best travel options for you, and helps us improve this system in the future. <br><br> Tap \"Next Step\" when you have selected the option that best describes your trip. If you do not know what to choose, select \"General Purpose\".");

  $('#purposepicker ul li').on('click', function(){
    var purposeSelect = $(this);
    var purposeId = purposeSelect.attr('name');

    //Part 1
    if ( purposeSelect.hasClass('selected')){
    //if class already exists on THIS li
      //do nothing
    } else {
      $('#purposepicker ul li').removeClass('selected');
      purposeSelect.addClass('selected');

      $('#trip_proxy_trip_purpose_id').val(purposeId);
    }
  });
});
