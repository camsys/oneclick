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

  //TO LABEL APPEAR
  $('input#trip_proxy_to_place').focus(function(){
      if (window.cocoa)
        window.cocoa.openKeyboard();
      $('#to_input').addClass('text-added');
  });
  $('input#trip_proxy_to_place').click(function(){
       if (window.cocoa)
        window.cocoa.openKeyboard();
  });
  $('input#trip_proxy_to_place').blur(function(){
    if (window.cocoa)
      window.cocoa.closeKeyboard();

    if($(this).val().length > 0){
      //do nothing
    } else {
      $('#to_input').removeClass('text-added');
    }
  });

  $('input#trip_proxy_to_place').focus();
});
