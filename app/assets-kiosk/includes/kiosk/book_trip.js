jQuery(function ($) {
  $('a[href="#book-ecolane"]').on('click', function(e) {
    e.preventDefault();
    if ($(this).hasClass('stop')) return true;
    var data = $(this).data();

    $(this).addClass('stop');

    var text = "<br>" + "#{t(:please_wait)}" + "..."
    $('#bookButton').html(text);

    $.ajax({
      url: "/users/" + data.traveler + "/trips/" + data.trip + "/book",
      data: {itin: data.itin},
      success: function(result) {
        var status         = result.trips[0]
          , returnStatus   = result.trips[2]
          , successMessage = false
          , hasError       = false;

        $('.ecolane-booking-results').show();

        // Show the error messages on failures.
        if (status == 'false')       hasError = true;
        if (returnStatus == 'false') hasError = true;

        if (!hasError) {
          // Show the confirmations on success
          if (status == 'true' && returnStatus == 'true')
            successMessage = ' #\'s: ' + result.trips[1] + ', ' + result.trips[3] + '.';
          else if (status == 'true')
            successMessage = ' #: ' + result.trips[1] + '.';
          else if (returnStatus == 'true')
            successMessage = ' #: ' + result.trips[3] + '.';
        }

        if (successMessage)
          $('.ecolane-booking-results .success').show().find('.numbers').html(successMessage);

        if (hasError)
          $('.error-message').show();
      },
      error: function() {
          $('.error-message').show();
      }
    })
  })
});
