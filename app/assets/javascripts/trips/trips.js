var tripformView = {};
tripformView.indexCounter = 0;
tripformView.formItems = [];


// INIT VIEW
tripformView.init = function(){
  this.formItems = $('*[data-index]');
  this.formItems.addClass('hidden');
  this.calendar = $('#trip-date').data('calendar');
  this.nextButton = $('.next-step-btn');
  this.tripDateCal = $('#trip-date');
  this.formEle = $('#new_trip_proxy');
  this.dateFormat = Date.parseFormat("mm/dd/yyyy");

  this.formEle.on('indexChange', tripformView.indexChangeHandler);

  $('input#trip_proxy_from_place').val('200 Peachtree Street Northeast, Atlanta, GA 30303');

  $('.next-step-btn, a#yes, a#no').on('click', tripformView.nextBtnHandler);

  //set calendar to today
  this.calendar.setDate(new Date());


  //reveal first form item
  $('*[data-index="0"]').removeClass('hidden');

  //disable pointer events on hidden trip form elements on the calendar
  this.tripDateCal.find('input').css('pointer-events', 'none');
  $('#trip_proxy_arrive_depart').css('pointer-events', 'none');
};

tripformView.overrideTaddaapicker = function() {
  //hijack all hide() method
  $.fn.datepicker.Calendar.prototype.hide = function() {};

  //remove click handler off document
  $(document).off('click');

  //hijack tadaapicker's internal method
  $.fn.datepicker.Calendar.prototype.mbShow = function() {

    var $cal = this.$cal, $target = this.$target;

    if (this.$target.data("dirty")) return; // focus event due to our field update

    if ($cal.hasClass("active")) {
      if ($cal.data("calendar") === this) {
        return; // already active for this input
      }
      Calendar.hide($cal);
    }

    var targetPos = $target.offset(),
      inputDate = this._parse($target.val());

    //targetPos is now static, change these values to change the calendar's position
    targetPos = {
      left: 597,
      top: 253
    };

    this.setDate(inputDate)
      .refreshDays() // coming from another input needs us to refresh the day headers
      .refresh().select();
    this.$cal.css({
      left: targetPos.left,
      top: targetPos.top + $target.outerHeight(false)
    }).addClass("active").data("calendar", this);

    // active key handler
    this._keyHandler = this.activeKeyHandler;


    //add click handler on calendar days to manually make them active
    $cal.find('td.day').on('click', function(e) {
      var $target = $(e.target);
      if (!$target.hasClass('new') && !$target.hasClass('old')) {
        $cal.find('td.day').removeClass('active');
        $target.addClass('active');
        $('#trip-date').datepicker().trigger('dateChange');
      }
    });
  };
};

///////////////////////////////////////////////////
// HANDLERS
//
//
///////////////////////////////////////////////////

tripformView.nextBtnHandler = function() {
  //increment counter
  tripformView.indexCounter++;
  //trigger indexchange event
  tripformView.formEle.trigger('indexChange');
};

//save form submit handler since we need to remove it if the user wants to edit their trip
tripformView.submitButtonhandler = function() {
  tripformView.formEle.submit();
};

tripformView.indexChangeHandler = function() {
  //hide everything again
  tripformView.formItems.addClass('hidden');

  //find element matching current index
  var matchedElement = $('div[data-index="' + tripformView.indexCounter +  '"]');

  // matched element visible
  matchedElement.removeClass('hidden');

  if (tripformView.indexCounter < 3){
    //if there's no from place input value, add stop class to next btn
    if ( $('#trip_proxy_from_place').val() === '' || $('#trip_proxy_to_place').val() === '' ) {
      tripformView.nextButton.addClass('stop');
    }
  }

  // we need to wait for ALL javascript to be done to start processing the indexchange event
  // something rails is doing is preventing us from doing custom actions on the datepicker -MB
  var readyState = setInterval(function() {
    if (document.readyState === "complete") {
      switch(tripformView.indexCounter) {
        case 1:

          $('div.next-footer-container').removeClass('hidden');
          $('#trip_map').show();

          tripformView.nextButtonValidate($('#trip_proxy_from_place'));
          break;

        case 2:
          tripformView.nextButtonValidate($('#trip_proxy_to_place'));
          break;

        case 3:
          //$('#trip-date').click();
          $('#trip_map').hide();

          //show the calendar
          tripformView.calendar.mbShow();

          //trigger a datechange event
          $('#trip-date').datepicker().trigger('dateChange');

          //update input field with the current time #why do i have to manually do this?!
          tripformView.tripDateCal.find('input').val(Date.format(new Date(), tripformView.dateFormat));
          break;

        case 4:
          $.fn.datepicker.Calendar.hide();
          //tripformView.calendar.$cal.hide();
          break;

        case 8:
          (function() {
            var leftResults = $('#left-results');
            $('#trip_map').show();

            $('#left-description').addClass('hidden');
            leftResults.removeClass('hidden');

            //pull input value from From section, add to results section
            var overviewFrom = $('#trip_proxy_from_place').val();
            //$('#left-results .from').html(overviewFrom);
            leftResults.find('.from').html(overviewFrom);

            //pull input value from To section, add to results section
            var overviewTo = $('#trip_proxy_to_place').val();
            //$('#left-results .to').html(overviewTo);
            leftResults.find('.to').html(overviewTo);

            //pull input value from Date section, add to results section
            var overviewDate = $('#trip_proxy_trip_date').val();
            //$('#left-results .date').html(overviewDate);
            leftResults.find('.date').html(overviewDate);

            //pull input value from From section, add to results section
            var overviewTime = $('#trip_proxy_trip_time').val();
            //$('#left-results .time').html(overviewTime);
            leftResults.find('.time').html(overviewTime);

            //if value exists
            //pull input value from From section, add to results section
            var overviewReturn = $('#trip_proxy_return_trip_time').val();
            //$('#left-results .return').html(overviewReturn);
            leftResults.find('.return').html(overviewReturn);

            //pull input value from From section, add to results section
            var overviewReason = $('#purposepicker ul li.selected').text();
            //$('#left-results .reason').html(overviewReason);
            leftResults.find('.reason').html(overviewReason);

            //$('.edit-trip-btn').removeClass('hidden');
            tripformView.editTripButtonInit();
            $.fn.datepicker.Calendar.hide();

            tripformView.nextButton.off('click', tripformView.nextBtnHandler);
            tripformView.nextButton.on('click', tripformView.submitButtonhandler);
          })();
          break;
      }
      clearInterval(readyState);
    }
  }, 10);
};

tripformView.nextButtonValidate = function($inputelem) {
  var tripProxyFromPlace = $inputelem;

  //add blur event handler to input field
  tripProxyFromPlace.on('blur', function() {
    if (tripProxyFromPlace.val() === '') {
      tripformView.nextButton.addClass('stop');
    }
    else {
      tripformView.nextButton.removeClass('stop');
    }
  });
};

tripformView.editTripButtonInit = function() {
  var tripButton = $('.edit-trip-btn');
  var leftResults = $('#left-results p.return');
  tripButton.removeClass('hidden');

  tripButton.off('click');

  tripButton.on('click', function(){
    $('*[data-index=1]').removeClass('hidden');
    //Unhide the return trip if it was hidden
    leftResults.show();
    leftResults.prev('h5').show();
    //hide the results and show the description
    $('#left-description').removeClass('hidden');
    $('#left-results, .edit-trip-btn').addClass('hidden');

    tripformView.indexCounter = 1;
    tripformView.nextButton.off('click', tripformView.submitButtonhandler);
    tripformView.nextButton.on('click', tripformView.nextBtnHandler);

    tripformView.formEle.trigger('indexChange');
  });
};



