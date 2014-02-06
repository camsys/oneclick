(function () {
  window.NewTrip = {};

  NewTrip.write = function (trip) {
    console.log(trip);
    return localStorage.setItem('trip', JSON.stringify(trip));
  };

  NewTrip.read = function () {
    return JSON.parse(localStorage.getItem('trip'));
  };

  NewTrip.start = function () {
    localStorage.removeItem('marker:start');
    localStorage.removeItem('marker:stop');
    this.write({});
  }

  NewTrip.update = function (attrs) {
    var trip = jQuery.extend(this.read(), attrs);
    this.write(trip);
  }

  NewTrip.timepickerInit = function (inputelemId, timepickerelemId) {
    // Set the selected time on a time picker widget
    function updateTimePicker (timeInput, timetable) {
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
    }

    function overrideTaddaapicker () {
      //hijack all hide() method
      $.fn.datepicker.Calendar.prototype.hide = function() {};

      //remove click handler off document
      $(document).off('click.datepicker');

      //hijack tadaapicker's internal method
      $.fn.datepicker.Calendar.prototype.mbShow = function() {
        var $cal = this.$cal
          , $target = this.$target;

        $('#trip-date').after($cal);

        if (this.$target.data("dirty")) return; // focus event due to our field update

        if ($cal.hasClass("active")) {
          if ($cal.data("calendar") === this) {
            return; // already active for this input
          }
          Calendar.hide($cal);
        }

        var targetPos = $target.offset()
          , inputDate = this._parse($target.find('input').val());

        //targetPos is now static, change these values to change the calendar's position
        targetPos = {
          left: 103,
          top: 124
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
    }

    overrideTaddaapicker();

    var isOutbound = (inputelemId == '#trip_proxy_trip_time');

    var timeInput = $(inputelemId);
    var timetable = $(timepickerelemId).find('.timetable');

    // Set the selected time on the outbound time picker widget
    updateTimePicker(timeInput, timetable);

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

      // if (!isOutbound) {
      //   // Update time on return trip time picker
      //   var timeElems = selectedTimeStr.split(':');
      //   var hour = parseInt(timeElems[0]);
      //   var minuteStr = timeElems[1];
      //   var ampmStr = selectedAmPmStr;

      //   if (hour >= 10) {
      //     // If time is 10:00 or later, but less then 12:00, switch the period
      //     if (hour < 12)
      //       ampmStr = (ampmStr == 'am') ? 'pm' : 'am';

      //     // If time is 11:00 or later, subtract 12
      //     if (hour >= 11) {
      //       hour -= 12;
      //     }
      //   }

      //   // Increment the hour by 2
      //   hour += 2;

      //   // Concatenate terms to create the return time string
      //   var returnTime = hour.toString() + ':' + minuteStr + ' ' + ampmStr;

      //   // Set the time value on the return time picker
      //   var returnTimeInput = $('#trip_proxy_return_trip_time');
      //   returnTimeInput.val(returnTime);

      //   // Get the return time picker widget
      //   var returnTimetable = $('#timepicker-two').find('.timetable');

      //   // Clear all selected times on the return time picker widget
      //   returnTimetable.find('li').removeClass('selected');

      //   // Set the selected time on the return time picker widget
      //   updateTimePicker(returnTimeInput, returnTimetable);
      // }
    });
  }

  NewTrip.stepCompleteHandler = function (e, xhr) {
    var data = xhr.responseJSON
      , hasErrors = false, errorArr = null, error = null;

    // Loop over the errors object and see if we have any errors
    for (var err in data.trip.errors) {
      hasErrors = true;

      // Get the error array for this field
      errorArr = data.trip.errors[err];

      // Take first error
      error = errorArr[0];

      // found an error so we can stop
      break;
    }

    if (hasErrors) {
      $('#trip-error').show();
      $('#trip-error-text').html(error);
    } else {
      $('#trip-error').hide();
      $('#trip-error-text').html('');
      NewTrip.update(data.trip);
      window.location = data.location;
    }
  };

  NewTrip.requirePresenceToContinue = function ($el) {
    //add blur event handler to input field
    $el.on('blur', function(e) {
      if ($(e.target).val() === '') {
        $('.next-step-btn').addClass('stop');
      } else {
        $('.next-step-btn').removeClass('stop');
      }
    });
  }
})();

