function viewSequence ($) {
  var els = $('*[data-index]');
  if(els.length < 1) return;

  function progress (e) {
    var nextIndex = els.index(els.filter('.current')) + 1
      , nextEl    = $(els[nextIndex]);

    els.addClass('hidden').removeClass('current');
    nextEl.removeClass('hidden').addClass('current');
    showNavButton()

    if (e) e.preventDefault();
  }

  function showNavButton () {
    if (els.filter('.current').hasClass('js-hide-nav-button')) {
      $('.next-footer-container').addClass('hidden');
    } else {
      $('.next-footer-container').removeClass('hidden');
    }
  }

  els.addClass('hidden');
  els.first().removeClass('hidden').addClass('current');
  showNavButton();

  $(document).on('click', '.js-progress-sequence', progress);

  $(document).on('click', '.next-step-btn', function () {

    if (els.filter('.current').is(els.last())) {
      $('.js-trip-wizard-form').submit();
    } else {
      progress();
    }
  });

};

function zoom_to_marker(marker) {
  if (marker) {
    //setMapToBounds();
    setMapToMarkerBounds(marker);
    selectMarker(marker);
  }
}

jQuery(function ($) {
  var tripformView = {}
    , geocoderMinChars = + $('meta[name="ui_min_geocode_chars"]')     .attr('content');

  viewSequence($);

  $('.js-trip-wizard-form').on('ajax:complete', NewTrip.stepCompleteHandler);
});
