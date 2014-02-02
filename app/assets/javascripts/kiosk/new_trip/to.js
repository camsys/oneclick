jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-to-wizard-step')) return;

  setupPlacesSearchTypeahead('to', 'stop');
});
