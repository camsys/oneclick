/**
 * Created by Miguel Bermudez on 12/6/13.
 */

//CG EDITS
//TODO: Create a module class for creating view
var tripformWrapper;

var tripformView = {
  indexCounter: 0,
  formItems: [],
  states: {
    HOME: 0,
    FROM: 1,
    TO: 2,
    TRAVELDATE: 3,
    TRAVELTIME: 4,
    PURPOSE: 5,
    RETURN: 6,
    RETURNTIME: 7,
    OVERVIEW: 8
  }
};

//var tripformWrapper = function() {
//  'use strict';

  /*..............................................................................
   * INIT
   *.............................................................................*/

  tripformView.init = function(){
    this.formItems = $('*[data-index]');
    this.formItems.addClass('hidden');
    this.calendar = $('#trip-date').data('calendar');
    this.nextButton = $('.next-step-btn');
    this.formEle = $('#new_trip_proxy');


    this.formEle.on('indexChange', tripformView.indexChangeHandler);

    //how to grab the TadaaPicker Obj from the dom element
    //$('#trip-date').data("calendar", tripformView).click();

    $('input#trip_proxy_from_place').val('200 Peachtree Street Northeast, Atlanta, GA 30303');

    $('.next-step-btn, a#yes').on('click', tripformView.nextBtnHandler);

    //reveal first form item
    $('*[data-index="0"]').removeClass('hidden');
  };


  tripformView.overrideTaddaapicker = function() {
    //hijack all hide() method
    $.fn.datepicker.Calendar.hide = function() {};
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
    };
  };


  /*..............................................................................
   * HANDLERS
   *.............................................................................*/

  tripformView.nextBtnHandler = function() {

    //increment counter
    tripformView.indexCounter++;

    //trigger indexchange event
    tripformView.formEle.trigger('indexChange');
  };

  tripformView.indexChangeHandler = function() {
    //hide everything again
    tripformView.formItems.addClass('hidden');

    //find element matching current index
    var matchedElement = $('div[data-index="' + tripformView.indexCounter +  '"]');

    // matched element visible
    matchedElement.removeClass('hidden');

    // this is really hacky ....
    // we need to wait for ALL javascript to be done to start processing the indexchange event
    // something rails is doing is preventing us from doing custom actions on the datepicker -MB
    var readyState = setInterval(function() {
      if (document.readyState === "complete") {

        switch(tripformView.indexCounter) {
          case tripformView.states.FROM:
            $('div.next-footer-container').removeClass('hidden');
            break;

          case tripformView.states.TRAVELDATE:
            //$('#trip-date').click();
            tripformView.calendar.mbShow();

            break;

          case tripformView.states.TRAVELTIME:
            //hide calendar when changing vies
            tripformView.calendar.$cal.hide();
            break;

          case tripformView.states.OVERVIEW:
            (function() {
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
              var overviewReason = $('#purposepicker').find('ul li.selected').text();
              //$('#left-results .reason').html(overviewReason);
              leftResults.find('.reason').html(overviewReason);

              $('.edit-trip-btn').removeClass('hidden');
              // in this form view (when index=8) change the next buttons click eventhandler
              tripformView.nextButton.off('click');
              tripformView.nextButton.on('click', function() {
                tripformView.formEle.submit();
              });
            })();
            break;
        }
        clearInterval(readyState);
      }
    }, 10);
  };

  // execute init view
  tripformView.init();

//};


/*..............................................................................
 * DOCUMENT READY
 *.............................................................................*/

$(document).ready(function(){
  'use strict';

  $.fn.datepicker.Calendar.setDefaultLocale("#{I18n.locale}");

  //tripformWrapper();

  //Override Tadaapicker's Calendar hide methods
  tripformView.overrideTaddaapicker();

  $('#trip-date').datepicker().on("dateChange", function(e) {
    $('#trip_proxy_trip_date').val(Date.format(e.date, "mm/dd/yyyy"));
  });

  $('#trip-time').timepicker({
    'timeFormat': 'g:i a',
    'scrollDefaultTime': '9:00 am'
  }).on("changeTime", function() {
      $('#trip_proxy_trip_time').val($('#trip-time').data('ui-timepicker-value'));
    });

  $('#return-trip-time').timepicker({
    'timeFormat': 'g:i a',
    'scrollDefaultTime': '10:00 am'
  }).on("changeTime", function(e) {
      $('#trip_proxy_return_trip_time').val($('#return-trip-time').data('ui-timepicker-value'));
    });

  $('.combobox').combobox({
    force_match: false
  });

  //DP CODE
  $('#purposepicker').find('ul li').on('click', function(){
    var purposeSelect = $(this);
    var purposeId = purposeSelect.attr('name');
    //Part 1

    if (!purposeSelect.hasClass('selected')) {
      $('#purposepicker').find('ul li').removeClass('selected');
      purposeSelect.addClass('selected');
      $('#trip_proxy_trip_purpose_id').val(purposeId);
    }
  });

  //create hidden input for TripPurposes
  //pass selected value into hidden input
  //which does it need the name, the id, something else?
  //submit the hidden value

  $('#return-yesno').find('a#no').on('click', function(){
    //Temporary Address.
    $('input#trip_proxy_from_place').val('Cemetery Drive, Decatur, GA 30033');
  });

  $('.edit-trip-btn').on('click', function(){
    $('*[data-index=1]').removeClass('hidden');
    tripformView.indexCounter = 1;
  });
  //END DP CODE

  // Hide what we don't need
  $('#from_place_candidates').hide();
  $('#to_place_candidates').hide();
  // Install a submit handler on the query form
  ajax_submit_form_handler('query_form');

  // Other setup
  $('.dropdown-toggle').dropdown();


  tripformView.init();

});