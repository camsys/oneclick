jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-to-wizard-step')) return;

  if ($('#trip_proxy_to_place').val() === '')
  	$('.next-step-btn').addClass('stop');
  NewTrip.requirePresenceToContinue($('#trip_proxy_to_place'));
  restore_marker_from_local_storage('stop');

  setupPlacesSearchTypeahead('to', 'stop');

  if (NewTrip.read().use_current_location == 'yes') {
    var $btn = $('.back-button .arrow-btn')
    $btn.attr('href', $btn.attr('href').replace('#back',''));
  }
});
