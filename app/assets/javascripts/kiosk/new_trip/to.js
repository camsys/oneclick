jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-to-wizard-step')) return;

  var nextButtonValidateToLocation = function() {
    var tripProxyPlace = $('#trip_proxy_to_place');

    //add blur event handler to input field
    tripProxyPlace.on('blur', function() {
        if (tripProxyPlace.val() === '') {
            $('.next-step-btn').addClass('stop');
        } else {
            $('.next-step-btn').removeClass('stop');
        }
    });
  }

  $('.next-step-btn').addClass('stop');
  nextButtonValidateToLocation();

  setupPlacesSearchTypeahead('to', 'stop');
});
