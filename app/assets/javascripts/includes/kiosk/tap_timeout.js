jQuery(function ($) {
  var secondsToAlert = $('meta[name="session_timeout"]')       .attr('content')
    , secondsToReset = $('meta[name="session_alert_timeout"]') .attr('content')
    , alertTimeout
    , resetTimeout
    , timerInterval
    , $tapTimeoutOverlay = $('.js-tap-timeout-overlay');

  if ($tapTimeoutOverlay.length < 1) return;

  function triggerAlert () {
    var counter = secondsToReset;
    resetTimeout = setTimeout(triggerReset, secondsToReset * 1000);

    $tapTimeoutOverlay
      .removeClass('hidden')
      .find('.js-counter').text(counter);

    timerInterval = setInterval(function () {
      counter -= 1;
      $tapTimeoutOverlay.find('.js-counter').text(counter);
    }, 1000);
  }

  function triggerReset () {
    window.location = '/kiosk/reset';
  }

  function start () {
    clearTimeout(alertTimeout);
    clearTimeout(resetTimeout);
    clearInterval(timerInterval);
    alertTimeout = setTimeout(triggerAlert, secondsToAlert * 1000);
  }

  timeout = setTimeout();

  if (window.location.pathname != '/kiosk') {
    $(document).on('click', function () {
      start();
      $tapTimeoutOverlay.addClass('hidden');
    });

    start();
  }
});
