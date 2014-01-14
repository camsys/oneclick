var tripformView = {};
tripformView.indexCounter = 0;
tripformView.formItems = [];


// INIT VIEW
tripformView.init = function(){
  this.formItems = $('*[data-index]');
  this.formItems.addClass('hidden');
  this.calendar = $('#trip-date').data('calendar');
  this.purposepickerSels = $('#purposepicker ul li');
  this.nextButton = $('.next-step-btn');
  this.tripDateCal = $('#trip-date');
  this.formEle = $('#new_trip_proxy');
  this.dateFormat = Date.parseFormat("mm/dd/yyyy");

  this.formEle.on('indexChange', tripformView.indexChangeHandler);

  $('input#trip_proxy_from_place').val('');

  // "Next Step", "Start at your current location?" -> NO, "Need a return trip?" -> YES
  $('.next-step-btn, #current-location a#no, #return-trip #yes').on('click', tripformView.nextBtnHandler);

  // "Start at your current location?" -> YES
  $('#current-location a#yes').on('click', tripformView.useCurrentLocationHandler);

  // "Need a return trip?" -> NO
  $('#return-trip a#no').on('click', tripformView.noReturnTripHandler);

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

tripformView.useCurrentLocationHandler = function() {
  
  // Increment counter by two, to skip "From" selection
  tripformView.indexCounter += 2;

  $('div.next-footer-container').removeClass('hidden');
  
  // Show the google map and re-calculate size. Have to do show() before reset to ensure
  // that leaflet code knows the size of the map, so it can calculate size correctly.
  $('#trip_map').show();
  resetMapView();

  // ***************
  // Currently hard-coding this in place -- synchrotron will be doing this in the future!!!!
  // ***************
  addrConfig.setCurrentMachineNameInField("machine1");

  // Synchrotron will have set the machine name, so we can get the machine address
  var item = JSON.parse(addrConfig.getCurrentMachineAddressInField());

  removeMatchingMarkers('start');

  // Create a marker to keep around, but don't display it on the map
  marker = create_or_update_marker('start', item.lat, item.lon, item.addr, getFormattedAddrForMarker(item.addr), 'startIcon');

  // Update the UI
  $('#from_place_selected_type').attr('value', item.type);
  $('#from_place_selected').attr('value', item.id);
  $('#trip_proxy_from_place').val(item.addr);

  //trigger indexchange event
  tripformView.formEle.trigger('indexChange');
}

tripformView.noReturnTripHandler = function() {

  // Register that we do not want a return trip
  $('#trip_proxy_is_round_trip').prop('checked', false);

  // Hide the "Return Trip" section on the trip summary
  $('#left-results p.return').hide();
  $('#left-results p.return').prev('h5').hide();

  // Set counter to go directly to Trip Overview page
  tripformView.indexCounter = 8;

  //trigger indexchange event
  tripformView.formEle.trigger('indexChange');
}

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

  // Hide the "Next Step" button on "Start at your current location?" and "Need a return trip?"
  if (tripformView.indexCounter == 0 || tripformView.indexCounter == 6) {
    tripformView.nextButton.hide();
  }
  else {
    tripformView.nextButton.show();
  }

  if (tripformView.indexCounter < 3){
    //if there's no from place input value, add stop class to next btn
    if ( $('#trip_proxy_from_place').val() === '' || $('#trip_proxy_to_place').val() === '' ) {
      tripformView.nextButton.addClass('stop');
    }
  }
  else if (tripformView.indexCounter == 5){
    //if there's nothing selected in the "purposes" list, add stop class to next btn
    if ($('#purposepicker ul li.selected').text() === '') {
      tripformView.nextButton.addClass('stop');
    }
  }

  // we need to wait for ALL javascript to be done to start processing the indexchange event
  // something rails is doing is preventing us from doing custom actions on the datepicker -MB
  var readyState = setInterval(function() {
    if (document.readyState === "complete") {

      var thisMarker; 

      switch(tripformView.indexCounter) {

        case 0:
          // "Start at your current location?"
          break;

        case 1:

          // Enter departure address
          $('div.next-footer-container').removeClass('hidden');
          
          // Show the google map and re-calculate size. Have to do show() before reset to ensure
          // that leaflet code knows the size of the map, so it can calculate size correctly.
          $('#trip_map').show();
          resetMapView(); // If you don't do this, map will be the size of a postage stamp!

          // Remove all markers from the map, but keep them around
          removeMarkersKeepCache();

          // Find the "start" marker -- if found, show it. Otherwise, show original map
          thisMarker = findMarkerById('start');

          if (thisMarker) {
            addMarkerToMap(thisMarker, false);
            zoom_to_marker(thisMarker);
          }
          else
            showMapOriginal();


          tripformView.nextButtonValidateLocation($('#trip_proxy_from_place'));
          $('#left-description p').html("Enter the address where you will start your trip. You can provide an address, the name of common landmarks or local businesses. The location you select will be shown on the map to confirm you have selected the correct location. <br><br> Tap \"Next Step\" when you have selected the correct starting location.");

          break;

        case 2:
          // Enter arrival address

          // Remove all markers from the map, but keep them around
          removeMarkersKeepCache();

          // Find the "stop" marker -- if found, show it. Otherwise, show original map
          thisMarker = findMarkerById('stop');

          if (thisMarker) {
            addMarkerToMap(thisMarker, false);
            zoom_to_marker(thisMarker);
          }
          else
            showMapOriginal();


          tripformView.nextButtonValidateLocation($('#trip_proxy_to_place'));
          $('#left-description h4').html("Tell Us Where You're Going");
          $('#left-description p').html("Enter the address where you will end your trip. You can provide an address, the name of common landmarks or local businesses. The location you select will be shown on the map to confirm you have selected the correct location. <br><br> Tap \"Next Step\" when you have selected the correct destination location.");


          break;

        case 3:
          // Date Picker
          $('#trip_map').hide();

          //show the calendar
          tripformView.calendar.mbShow();
          $('#left-description h4').html("Tell Us What Day You'll Be Leaving");
          $('#left-description p').html("Choose the date you will be leaving from your starting location. Today's date has already been selected for you. <br><br> Tap \"Next Step\" when you have selected the correct date to leave.");


          break;

        case 4:
          // Time Picker (outbound trip)
          $.fn.datepicker.Calendar.hide();

          // Initialize time picker for outbound trip
          tripformView.timepickerInit('#trip_proxy_trip_time', '#timepicker-one');

          // Initialize time picker for return trip -- doing it here, even if we don't need it, because we will
          // be updating it based on selections in outbound trip date picker
          tripformView.timepickerInit('#trip_proxy_return_trip_time', '#timepicker-two');
          $('#left-description h4').html("Tell Us What Time You'll Be Leaving");
          $('#left-description p').html("Choose the time you will be leaving from your starting location. The next hour or half-hour has already been selected for you. <br><br> Tap \"Next Step\" when you have selected the correct time to leave.");

          break;

        case 5:
          // Purposes
          tripformView.nextButtonValidatePurpose();
          $('#left-description h4').html("Tell Us Why You Are Making This Trip");
          $('#left-description p').html("Choose the option that best describes why you are making this trip. Providing this information helps us provide the best travel options for you, and helps us improve this system in the future. <br><br> Tap \"Next Step\" when you have selected the option that best describes your trip. If you do not know what to choose, select \"General Purpose\".");

          break;

        case 6:
          // "Need a Return Trip?"
          $('#left-description h4').html("Tell Us About Your Return Trip");
          $('#left-description p').html("Would you like to see options for a return trip? Tap \"yes\" or \"no\". If \"yes\", you will be prompted to enter a return time (that is, a time to be picked up at your destination) in the next step.");

          break;

        case 7:
          // Time Picker (return trip)
          $('#left-description h4').html("Tell Us When You'll Be Ready To Return");
          $('#left-description p').html("Choose the time you will be leaving your destination location, to return back to your starting location. A time 2 hours from the departure time you chose has already been selected for you.<br><br>Tap \"Next Step\" when you have selected the correct time to leave your destination.");

          break;

        case 8:
          // Trip overview
          (function() {

            // Show the map at the full-panel size
            $('#lmap').css('height','690px');
            $('#_GMapContainer').css('height','690px');
            $('#trip_map').show();

            // Show the start & end pins and ensure proper zoom/pan
            refreshMarkers();
            setMapToBounds();

            // Do this last
            invalidateMap();

            var leftResults = $('#left-results');

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

tripformView.nextButtonValidateLocation = function($inputelem) {
  var tripProxyPlace = $inputelem;

  //add blur event handler to input field
  tripProxyPlace.on('blur', function() {
    if (tripProxyPlace.val() === '') {
      tripformView.nextButton.addClass('stop');
    }
    else {
      tripformView.nextButton.removeClass('stop');
    }
  });
};

tripformView.nextButtonValidatePurpose = function() {
  // Enable the "Next Step" button when the user clicks on one of the list elements
  tripformView.purposepickerSels.on('click', function() {
    tripformView.nextButton.removeClass('stop');
  });
};

tripformView.timepickerInit = function(inputelemId, timepickerelemId) {
  var isOutbound = (inputelemId == '#trip_proxy_trip_time');

  var timeInput = $(inputelemId);
  var timetable = $(timepickerelemId).find('.timetable');

  // Set the selected time on the outbound time picker widget
  tripformView.updateTimePicker(timeInput, timetable);

  //add click event to time items
  timetable.find('li').not('.notime').on('click', function(e) {
    var target = $(e.target);

    //clear time
    if(target.hasClass('ampm') === false) {
      //clear all time selected
      //Unhide the return trip if it was hidden
      timetable.find('li').not('.ampm').removeClass('selected');
    } else {
      timetable.find('.ampm').removeClass('selected');
    }
    //add selected class to target
    target.addClass('selected');

    //create val for input
    var selectedTimeElems = timetable.find('li.selected');
    var selectedTimeStr = $(selectedTimeElems[0]).text();
    var selectedAmPmStr = $(selectedTimeElems[1]).text();
    var timeval = selectedTimeStr + " " + selectedAmPmStr;
    
    timeInput.val(timeval);

    if (isOutbound) {
      // Update time on return trip time picker
      var timeElems = selectedTimeStr.split(':');
      var hour = parseInt(timeElems[0]);
      var minuteStr= timeElems[1];
      var ampmStr = selectedAmPmStr;

      if (hour >= 10) {
        // If time is 10:00 or later, but less then 12:00, switch the period
        if (hour < 12)
          ampmStr = (ampmStr == 'am') ? 'pm' : 'am';

        // If time is 11:00 or later, subtract 12
        if (hour >= 11) {
          hour -= 12;
        }
      }

      // Increment the hour by 2
      hour += 2;

      // Concatenate terms to create the return time string
      var returnTime = hour.toString() + ':' + minuteStr + ' ' + ampmStr;

      // Set the time value on the return time picker
      var returnTimeInput = $('#trip_proxy_return_trip_time');
      returnTimeInput.val(returnTime);

      // Get the return time picker widget
      var returnTimetable = $('#timepicker-two').find('.timetable');
      
      // Clear all selected times on the return time picker widget
      returnTimetable.find('li').removeClass('selected');

      // Set the selected time on the return time picker widget
      tripformView.updateTimePicker(returnTimeInput, returnTimetable);
    }

  });
};

// Set the selected time on a time picker widget
tripformView.updateTimePicker = function(timeInput, timetable) {

  // Read the time from the input field and split it on a space character
  var timeTokens = timeInput.val().split(' ');
 
  // Define selectors for finding the right time elements
  var liTimeSelector = 'li:contains("' + timeTokens[0] + '")';
  var liAmPmSelector = 'li:contains("' + timeTokens[1] + '")';
 
  // Use the selectors to find the right time elements
  var timeElem = timetable.find(liTimeSelector).first();
  var amPmElem = timetable.find(liAmPmSelector);
 
  // Now that we have the right time elements, set them selected
  timeElem.addClass('selected');
  amPmElem.addClass('selected');
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
     $('#left-description h4').html("Tell Us Where You're Starting");
     $('#left-description p').html("Will you be traveling from your current location? Tap \"yes\" or \"no\". If \"no\", you will be prompted to enter an address to travel from in the next step.");
     $('#lmap').css('height','558px');
     $('#_GMapContainer').css('height','558px');

    tripformView.indexCounter = 1;
    tripformView.nextButton.off('click', tripformView.submitButtonhandler);
    tripformView.nextButton.on('click', tripformView.nextBtnHandler);

    tripformView.formEle.trigger('indexChange');
  });
};




