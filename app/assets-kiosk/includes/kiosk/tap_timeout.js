window.TapTimeout = {
    paused: false,

    pause: function () {
        this.reset();
        this.paused = true;
        return "Paused Timeout.";
    },

    unpause: function () {
        this.paused = false;
        this.reset();
        return "Unpaused Timeout.";
    }
}

jQuery(function($) {
    var secondsToAlert = $('meta[name="session_timeout"]').attr('content'),
        secondsToReset = $('meta[name="session_alert_timeout"]').attr('content'),
        alertTimeout, resetTimeout, timerInterval, $tapTimeoutOverlay = $('.js-tap-timeout-overlay');

    if ($tapTimeoutOverlay.length < 1) return;

    function triggerAlert() {
        if (TapTimeout.paused) return reset();

        var counter = secondsToReset;
        resetTimeout = setTimeout(triggerReset, secondsToReset * 1000);

        $tapTimeoutOverlay
            .removeClass('hidden')
            .find('.js-counter').text(counter);

        timerInterval = setInterval(function() {
            counter -= 1;
            $tapTimeoutOverlay.find('.js-counter').text(counter);
        }, 1000);
    }

    function triggerReset() {
        if (TapTimeout.paused) return reset();

        if (window.cocoa)
            window.cocoa.closeKeyboard();

        window.location = '/kiosk/reset';
    }

    function start() {
        clearTimeout(alertTimeout);
        clearTimeout(resetTimeout);
        clearInterval(timerInterval);
        if (TapTimeout.paused) return;
        alertTimeout = setTimeout(triggerAlert, secondsToAlert * 1000);
    }

    function reset () {
        start();
        $tapTimeoutOverlay.addClass('hidden');
    }

    if (window.location.pathname != '/kiosk') {
        $(document).on('click', reset);
        start();
    }

    window.TapTimeout.reset = reset;
});
