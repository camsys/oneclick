function viewSequence ($) {
  var els   = $('*[data-index]')
    , texts = $('.js-sidebar-text-series > .sidebar-text')
    , firstEl;
  if(els.length < 1) return;

  function showFrameForIndex(index) {
    // show the page section at the given index
    els.addClass('hidden').removeClass('current');
    els.eq(index).removeClass('hidden').addClass('current');

    // show the corresponding sidebar text
    texts.addClass('hidden');
    texts.eq(index).removeClass('hidden');

    updateMap();
    showNavButton();
  }

  function changeFrames(e, dir) {
    var nextIndex = els.index(els.filter('.current')) + dir;

    showFrameForIndex(nextIndex);

    if (e) e.preventDefault();
  }

  function progress (e) {
    changeFrames(e, 1);
  }

  function goBack (e) {
    changeFrames(e, -1);
  }

  function updateMap() {
    if (els.filter('.current').hasClass('location-from')) {
      // Show the google map and re-calculate size. Have to do show() before reset to ensure
      // that leaflet code knows the size of the map, so it can calculate size correctly.
      $('#trip_map').show();
      resetMapView(); // If you don't do this, map will be the size of a postage stamp!
    }
  }

  function showNavButton () {
    if (els.filter('.current').hasClass('js-hide-nav-button')) {
      $('.next-footer-container').addClass('hidden');
    } else {
      $('.next-footer-container').removeClass('hidden');
    }
  }

  if (window.location.hash == '#back') {
    showFrameForIndex(els.length - 1);
  } else {
    showFrameForIndex(0);
  }

  $(document).on('click', '.js-progress-sequence', progress);

  $(document).on('click', '.next-step-btn', function () {
    if (els.filter('.current').is(els.last())) {
      $('.js-trip-wizard-form').submit();
    } else {
      progress();
    }
  });

  $(document).on('click', '.back-button a', function (e) {
    if (els.filter('.current').is(els.first())) {
      $(e.target)
    } else {
      goBack(e);
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

function setInputToLocalValue ($input, key, value) {
  // hardcoding.
  var booleanProperties = ['trip_proxy[is_round_trip]'];

  if ($.inArray($input.prop('name'), booleanProperties) != -1) {
    if ($input.prop('type') != 'hidden')
      $input.prop('checked', (value == '1'));
  } else {
    $input.val(value);
  }
}

jQuery(function ($) {
  if ($('.js-trip-wizard-form').length < 1) return;
  viewSequence($);

  $('.js-trip-wizard-form input').each(function () {
    $input = $(this);
    var result = $input.prop('name').match(/trip_proxy\[(.*)\]/);

    if (result && typeof NewTrip.read()[result[1]] != 'undefined') {
      setInputToLocalValue($input, result[1], NewTrip.read()[result[1]]);
    }
  });

  $('.js-trip-wizard-form').on('ajax:complete', NewTrip.stepCompleteHandler);
});
