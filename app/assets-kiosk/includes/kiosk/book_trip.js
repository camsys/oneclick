jQuery(function ($) {
  $('a[href="#book-ecolane"]').on('click', function(e) {
    e.preventDefault();
    var data = $(this).data();

    var text = "<br>" + "#{t(:please_wait)}" + "..."
    $('#bookButton').html(text);

    $.ajax({
      url: "/users/" + data.traveler + "/trips/" + data.trip + "/book",
      data: {itin: data.itin},
      success: function(result) {
        debugger;
        // status = result['trips'][0];
        // return_status = result['trips'][2];
        // $('#outbound_results').show();
        // $('#bookButton').hide();
        // $('#bookingTitle').html("#{t(:trip_booked)}");
        // $('#headerMessage').html("#{t(:trip_booked_2)}");
        // $('#bookingQuestion').html("");

        // //Show the confirmations on success
        // if (status == "true" && return_status == "true") {
        //   var text1 = "#{t(:confirmation)}" + " #'s: ";
        //   text1 += result['trips'][1]['confirmation'] + ', ' + result['trips'][3]['confirmation'] + '.';
        //   $('#outbound_results1').html(text1);
        // }
        // else if(status == "true") {
        //   var text1 = "Confirmation #: ";
        //   text1 += result['trips'][1]['confirmation'] + '.'
        //   $('#outbound_results1').html(text1);
        // }
        // else if(return_status == "true"){
        //   var text1 = "Confirmation #: ";
        //   text1 += result['trips'][3]['confirmation'] + '.'
        //   $('#outbound_results1').html(text1);
        // }

        // //Show the error messages on failures.
        // if (status == "false") {
        //   var text2 = "<br>" + "#{t(:outbound_error_occurred)}"
        //   $('#outbound_results2').html(text2);
        //   var text3 = result['trips'][1]['trips'][0];
        //   $('#outbound_results3').html(text3);
        // }

        // if (return_status == "false") {
        //   var text4 = "<br>" + "#{t(:return_error_occurred)}"
        //   $('#outbound_results4').html(text4);
        //   var text5 = result['trips'][3]['trips'][0];
        //   $('#outbound_results5').html(text5);
        // }

        // console.log(text6);
        // $('#outbound_results6').html(text6);
      },
      error: function(){
        $('#outbound_results1').html("error");
      }
    })
  })
});
