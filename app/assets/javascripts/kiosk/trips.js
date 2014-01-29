jQuery(function ($) {
(function () {
if ($('.js-trip-wizard-form').length > 0) return;
// -- END START OF DISABLING CODE -- !://

var tripformView = {};
tripformView.indexCounter = 0;
tripformView.formItems = [];


// INIT VIEW
tripformView.init = function() {
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
  var matchedElement = $('div[data-index="' + tripformView.indexCounter + '"]');

  // matched element visible
  matchedElement.removeClass('hidden');

  // Hide the "Next Step" button on "Start at your current location?" and "Need a return trip?"
  if (tripformView.indexCounter == 0 || tripformView.indexCounter == 6) {
    tripformView.nextButton.hide();
  } else {
    tripformView.nextButton.show();
  }

  if (tripformView.indexCounter < 3) {
    //if there's no from place input value, add stop class to next btn
    if ($('#trip_proxy_from_place').val() === '' || $('#trip_proxy_to_place').val() === '') {
      tripformView.nextButton.addClass('stop');
    }
  } else if (tripformView.indexCounter == 5) {
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

      switch (tripformView.indexCounter) {
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
        } else
          showMapOriginal();


        tripformView.nextButtonValidateLocation($('#trip_proxy_from_place'));
        $('#left-description p').html("Enter the address where you will start your trip. You can provide an address, the name of common landmarks or local businesses. The location you select will be shown on the map to confirm you have selected the correct location. <br><br> Tap \"Next Step\" when you have selected the correct starting location.");

        // If text input is empty, bring focus, which should open keyboard
        if ($('#from_place_selected').val() == "")
        $('input#trip_proxy_from_place').focus();

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
        } else
          showMapOriginal();


        // If text input is empty, bring focus, which should open keyboard
        if ($('#to_place_selected').val() == "")
        $('input#trip_proxy_to_place').focus();
            tripformView.nextButtonValidateLocation($('#trip_proxy_to_place'));
            $('#left-description h4').html("Tell Us Where You're Going");
            $('#left-description p').html("Enter the address where you will end your trip. You can provide an address, the name of common landmarks or local businesses. The location you select will be shown on the map to confirm you have selected the correct location. <br><br> Tap \"Next Step\" when you have selected the correct destination location.");


        break;

      case 3:
        // Date Picker
        debugger;
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
          $('#lmap').css('height', '690px');
          $('#_GMapContainer').css('height', '690px');
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

          //rename the Next Step button to say Plan my Trip
          $('.next-step-btn h1').html('Plan my Trip');

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
    } else {
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
    if (target.hasClass('ampm') === false) {
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
      var minuteStr = timeElems[1];
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

  tripButton.on('click', function() {
    $('*[data-index=1]').removeClass('hidden');
    //Unhide the return trip if it was hidden
    leftResults.show();
    leftResults.prev('h5').show();
    //update the large blue button to read Next Step once again
    $('.next-step-btn h1').html('Next Step');
    //hide the results and show the description
    $('#left-description').removeClass('hidden');
    $('#left-results, .edit-trip-btn').addClass('hidden');
    $('#left-description h4').html("Tell Us Where You're Starting");
    $('#left-description p').html("Will you be traveling from your current location? Tap \"yes\" or \"no\". If \"no\", you will be prompted to enter an address to travel from in the next step.");
    $('#lmap').css('height', '558px');
    $('#_GMapContainer').css('height', '558px');

    tripformView.indexCounter = 1;
    tripformView.nextButton.off('click', tripformView.submitButtonhandler);
    tripformView.nextButton.on('click', tripformView.nextBtnHandler);

    tripformView.formEle.trigger('indexChange');
  });
};

// -- BREAKBREAK -- !://
// Configure UI behaviors
// Configure UI behaviors
var typeahead_delay = +"#{Rails.application.config.ui_typeahead_delay}";
var typeahead_min_chars = +"#{Rails.application.config.ui_typeahead_min_chars}";
var typeahead_list_length = +"#{Rails.application.config.ui_typeahead_list_length}";
var geocoder_min_chars = +"#{Rails.application.config.ui_min_geocode_chars}";


///////////////////////////////////////////////////
// LISTENERS
//
//
///////////////////////////////////////////////////
// Add change listeners on the text fields
$("#trip_proxy_from_place").bind("keyup input paste", function() {
  $('#from_place_selected').val("");
  $('#from_place_selected_type').val("");
  $('#from_place_candidates').hide();
  removeMatchingMarkers('start');
});
$("#trip_proxy_to_place").bind("keyup input paste", function() {
  $('#to_place_selected').val("");
  $('#to_place_selected_type').val("");
  $('#to_place_candidates').hide();
  removeMatchingMarkers('stop');
});

///////////////////////////////////////////////////
// ACTIONS
//
//
///////////////////////////////////////////////////

// user has lost focus on the from address
$('#trip_proxy_from_place').blur(function() {
  if ($('#from_place_selected').val() == "") {
    // Do an ajax query to geocode the input text
    var addr = $('#trip_proxy_from_place').val().trim();
    if (addr.length >= geocoder_min_chars) {
      $('#query').val(addr);
      $('#target').val(0);
      $('#query_form').submit();
      $('#from_geocoding_indicator').show();
    }
  }
});

// user has lost focus on the to address
$('#trip_proxy_to_place').blur(function() {
    if ($('#to_place_selected').val() == "") {
    // Do an ajax query to geocode the input text
    var addr = $('#trip_proxy_to_place').val().trim();
    if (addr.length >= geocoder_min_chars) {
      $('#query').val(addr);
      $('#target').val(1);
      $('#query_form').submit();
      $('#to_geocoding_indicator').show();
    }
  }
});

// User has selected a pre-defined place from the dropdown.
$('.place-option').on('click', function(event) {
  var t = $(event.target);
  var id = t.data('id');
  var from_to = t.data('type');
  var name = t.data('value');
  var desc = t.data('desc');
  var latlon = eval(t.data('latlon'));
  var iconStyle = 'startIcon';
  var key;
  if (from_to == 'from') {
    $('#from_place_selected').val(id);
    $('#from_place_selected_type').val(3);
    $('#from_place_candidates').hide();
    key = 'start';
  } else {
    iconStyle = 'stopIcon';
    $('#to_place_selected').val(id);
    $('#to_place_selected_type').val(3);
    $('#to_place_candidates').hide();
    key = 'stop';
  }
  removeMatchingMarkers(key);
  var marker = create_or_update_marker(key, latlon[0], latlon[1], name, desc, iconStyle);
  zoom_to_marker(marker);

  $('#' + t.parents('ul').data('target')).val(name);
});


var from_timeout;
var to_timeout;

// Enable typeahead for the places forms
$('#trip_proxy_from_place').typeahead({
    items: typeahead_list_length,
    minLength: typeahead_min_chars,
    source: function(query, process) {
        if (from_timeout) {
          clearTimeout(from_timeout);
        }
        from_timeout = setTimeout(function() {
            return $.ajax({
                url: $('#trip_proxy_from_place').data('link'),
                type: 'get',
                data: {
                  query: query
                },
                dataType: 'json',
                success: function(result) {

                  var resultList = result.map(function (item) {
                      var aItem = { index: item.index, type: item.type, id: item.id, name: item.name, desc: item.description, lat: item.lat, lon: item.lon, addr: item.address };
                      return JSON.stringify(aItem);
                  });

                  return process(resultList);
                },
                error: function (data) {
                    show_alert("We are sorry but something went wrong. Please try again.");
                }
            });
        }, typeahead_delay);
    },
  matcher: function (obj) {
      var item = JSON.parse(obj);
      return ~item.name.toLowerCase().indexOf(this.query.toLowerCase())
  },

  sorter: function (items) {
     var beginswith = [], caseSensitive = [], caseInsensitive = [], item;
      while (aItem = items.shift()) {
          var item = JSON.parse(aItem);
          if (!item.name.toLowerCase().indexOf(this.query.toLowerCase())) beginswith.push(JSON.stringify(item));
          else if (~item.name.indexOf(this.query)) caseSensitive.push(JSON.stringify(item));
          else caseInsensitive.push(JSON.stringify(item));
      }

      return beginswith.concat(caseSensitive, caseInsensitive)

  },


  highlighter: function (obj) {
      var item = JSON.parse(obj);
      var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
      return item.name.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
          return '<strong>' + match + '</strong>'
      })
  },

  updater: function (obj) {
      var item = JSON.parse(obj);

      // create marker on the map
      removeMatchingMarkers('start');
      marker = create_or_update_marker('start', item.lat, item.lon, item.name, item.desc, 'startIcon');
      zoom_to_marker(marker);

      // Update the UI
      $('#from_place_selected_type').attr('value', item.type);
      $('#from_place_selected').attr('value', item.id);

      return item.name;
  }
});

// Enable typeahead for the places forms
$('#trip_proxy_to_place').typeahead({
    items: typeahead_list_length,
    minLength: typeahead_min_chars,
    source: function(query, process) {
        if (to_timeout) {
          clearTimeout(to_timeout);
        }
        to_timeout = setTimeout(function() {
            return $.ajax({
                url: $('#trip_proxy_to_place').data('link'),
                type: 'get',
                data: {
                  query: query
                },
                dataType: 'json',
                success: function(result) {

                  var resultList = result.map(function (item) {
                      var aItem = { index: item.index, type: item.type, id: item.id, name: item.name, desc: item.description, lat: item.lat, lon: item.lon, addr: item.address };
                      return JSON.stringify(aItem);
                  });

                  return process(resultList);
                },
                error: function (data) {
                    show_alert("We are sorry but something went wrong. Please try again.");
                }
            });
        }, typeahead_delay);
    },
  matcher: function (obj) {
      var item = JSON.parse(obj);
      return ~item.name.toLowerCase().indexOf(this.query.toLowerCase())
  },

  sorter: function (items) {
     var beginswith = [], caseSensitive = [], caseInsensitive = [], item;
      while (aItem = items.shift()) {
          var item = JSON.parse(aItem);
          if (!item.name.toLowerCase().indexOf(this.query.toLowerCase())) beginswith.push(JSON.stringify(item));
          else if (~item.name.indexOf(this.query)) caseSensitive.push(JSON.stringify(item));
          else caseInsensitive.push(JSON.stringify(item));
      }

      return beginswith.concat(caseSensitive, caseInsensitive)

  },


  highlighter: function (obj) {
      var item = JSON.parse(obj);
      var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
      return item.name.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
          return '<strong>' + match + '</strong>'
      })
  },

  updater: function (obj) {
      var item = JSON.parse(obj);

      // create marker on the map
      removeMatchingMarkers('stop');
      marker = create_or_update_marker('stop', item.lat, item.lon, item.name, item.desc, 'stopIcon');
      zoom_to_marker(marker);

      // Update the UI
      $('#to_place_selected_type').attr('value', item.type);
      $('#to_place_selected').attr('value', item.id);

      return item.name;
    }
});

///////////////////////////////////////////////////
// FUNCTIONS
//
//
///////////////////////////////////////////////////

function create_or_update_marker(key, lat, lon, name, desc, iconStyle) {
  // See if we can find this existing marker
  marker = findMarkerById(key);
  if (marker) {
    removeMarkerFromMap(marker);
  }
  var marker = createMarker(key, lat, lon, iconStyle, desc, name, true);
  addMarkerToMap(marker, true);
  return marker;
};

// Add a list of candidate markers to the map
var alphabet = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'Z', 'Y', 'Z'];

function add_candidate_marker(index, lat, lon, addr, desc, type) {
  var iconStyle;
  var key_template;
  if (type == 'from') {
    iconStyle = 'startCandidate';
    key_template = 'start_candidate';
  } else if (type == 'to') {
    iconStyle = 'stopCandidate';
    key_template = 'stop_candidate';
  } else {
    iconStyle = 'placeCandidate';
    key_template = 'place_candidate';
  }
  var icon = iconStyle + alphabet[index];
  var key = key_template + index;
  var marker = createMarker(key, lat, lon, icon, desc, addr, false);
  addMarkerToMap(marker, true);
}

// Add the candidate locations to the map
function create_candidate_markers(from_to_type) {
  $('.address-select').each(function() {
    var t = $(this);
    var id = t.data('id');
    var index = t.data('index');
    var type = t.data('type');
    var addr = t.data('addr');
    var desc = t.data('desc');
    var latlon = eval(t.data('latlon'));
    if (type === from_to_type) {
      add_candidate_marker(index, latlon[0], latlon[1], addr, desc, type);
    }
  });
};

// Selects the first matching from or to candidate in the list of alternate
// addresses.
function select_first_candidate_address(from_to) {
  $('.address-select').each(function(idx) {
    var candidate = $(this);
    var type = candidate.data('type');
    if (type == from_to) {
      select_candidate_address(candidate);
      return;
    }
  });
};

// Select a candidate address
function select_candidate_address(candidate) {
  var id = candidate.data('id');
  var index = candidate.data('index');
  var type = candidate.data('type');
  var addr = candidate.data('addr');
  var desc = candidate.data('desc');
  var latlon = eval(candidate.data('latlon'));

  var update_target;
  var hidden_val;
  var hidden_type;
  var panel;
  var key = 'start';
  var iconStyle = 'startIcon';
  if (type == 'from') {
    update_target = $('#trip_proxy_from_place');
    hidden_val = $('#from_place_selected');
    hidden_type = $('#from_place_selected_type');
    panel = $('#from_place_candidates');
  } else {
    update_target = $('#trip_proxy_to_place');
    hidden_val = $('#to_place_selected');
    hidden_type = $('#to_place_selected_type');
    panel = $('#to_place_candidates');
    key = 'stop';
    iconStyle = 'stopIcon';
  }
  hidden_val.val(index);
  hidden_type.val(4);
  panel.hide();
  update_target.val(addr);

  // Remove any candidate markers from the map
  removeMatchingMarkers(key);
  // replace the markers with the end point marker
  marker = create_or_update_marker(key, latlon[0], latlon[1], addr, desc, iconStyle);
  zoom_to_marker(marker);
};

//Only Allow One Checkbox to Be Checked
$('#trip_proxy_to_is_home').change(function() {
  $('#trip_proxy_from_is_home').prop('checked', 0);
});

$('#trip_proxy_from_is_home').change(function() {
  $('#trip_proxy_to_is_home').prop('checked', 0);
});


///////////////////////////////////////////////////
// Document Ready
//
//
///////////////////////////////////////////////////
$(document).ready(function(){
  //DP CODE
  $('#purposepicker ul li').on('click', function(){
    var purposeSelect = $(this);
    var purposeId = purposeSelect.attr('name');
    //Part 1
    if ( purposeSelect.hasClass('selected')){
    //if class already exists on THIS li
      //do nothing
    } else {
      $('#purposepicker ul li').removeClass('selected');
      purposeSelect.addClass('selected');

      $('#trip_proxy_trip_purpose_id').val(purposeId);
    }
  });

  //FROM LABEL APPEAR
  $('input#trip_proxy_from_place').focus(function(){
      if (window.cocoa)
        window.cocoa.openKeyboard();
      $('#from_input').addClass('text-added');
  });

  $('input#trip_proxy_from_place').click(function(){
       if (window.cocoa)
        window.cocoa.openKeyboard();
  });

  $('input#trip_proxy_from_place').blur(function(){
    if($(this).val().length > 0){
      //do nothing
    } else {
      $('#from_input').removeClass('text-added');
    }
  });

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
    if($(this).val().length > 0){
      //do nothing
    } else {
      $('#to_input').removeClass('text-added');
    }
  });

  $('.edit-trip-btn').on('click', function(){
    $('*[data-index=1]').removeClass('hidden');
    //Unhide the return trip if it was hidden
    $('#left-results p.return').show();
    $('#left-results p.return').prev('h5').show();
    //hide the results and show the description
    $('#left-description').removeClass('hidden');
    $('#left-results, .edit-trip-btn').addClass('hidden');

    tripformView.indexCounter = 1;
    tripformView.formEle.trigger('indexChange');
  });

  //END DP CODE

  // Hide what we don't need
  $('#from_place_candidates').hide();
  $('#to_place_candidates').hide();

  // Install a submit handler on the query form
  ajax_submit_form_handler('query_form');

  // Other setup
  $('.dropdown-toggle').dropdown();

  // hide all form items to prevent flash of itms on screen
  //$('*[data-index]').addClass('hidden');

  // excute init view
  tripformView.init();
});

// -- END DISABLING CODE -- !://
})();
});
