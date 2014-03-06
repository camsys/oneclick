jQuery(function ($) {
  if (!$('.js-trip-wizard-form').hasClass('js-start-wizard-step')) return;

  NewTrip.start();
  window.location = String(window.location).replace('start', 'from');
});
