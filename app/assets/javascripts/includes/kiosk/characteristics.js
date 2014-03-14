jQuery(function ($) {
(function () {
if ($('.js-trip-wizard-form').length > 0) return;
// -- END START OF DISABLING CODE -- !://

/**
 * Created by Miguel Bermudez on 12/9/13.
 */

var dobFirst;
window.characteristicsView = {
  indexCounter: 0,
  dobView: false,
  formItems: [],
  dobItems: [],
  states: {
    YESNO: 0,
    QUESTIONS: 1,
    DOB: 2,
    PROGRAMS: 3,
    TRAVELTIME: 4,
    PURPOSE: 5,
    RETURN: 6,
    RETURNTIME: 7,
    OVERVIEW: 8
  },
  dob: {
    counter: 0,
    states: {
      MONTH: 1,
      DAY: 2,
      YEAR: 0
    },

    yearpage: 0,
    params: {},

    //get number of days for a particular month, months are 0 based
    numberOfDays: function(month) {
      var now = new Date();
      var m = month + 1;
      var d = new Date(now.getUTCFullYear(), m, 0);
      return d.getDate();
    }
  }
};

/*..............................................................................
 * Characteristics Form View Init
 *.............................................................................*/
characteristicsView.init = function () {
  "use strict";

  //cache all form items
  this.formItems = $('*[data-index]');
  this.formItems.addClass('hidden');
  this.dobItems = $('.dob-section', '.new_user_characteristics_proxy');
  this.dob.breadcrumbs = $('.dob-breadcrumb li');
  this.dob.monthtable = $('#monthtable');
  this.dob.daytable = $('#daytable');
  this.dob.yeartable = $('#yeartable');
  this.dob.yearlist = $('#yearlist');

  //add indexChange handler to form
  $('#eligibility_form').on('indexChange', characteristicsView.indexChangeHandler.bind(characteristicsView));

  //add click handler to next button
  $('.next-step-btn, a#yes').on('click', characteristicsView.nextBtnHandler.bind(characteristicsView));

  $('.back-button').on('click', characteristicsView.backBtnHandler.bind(characteristicsView));

  //add click handlers to dob form li elements (table)
  characteristicsView.dobItems.on('click', 'li', characteristicsView.handleDobElemClick.bind(characteristicsView));

  //reveal first form item
  if (window.location.hash != '#back') {
    $('*[data-index=0]').removeClass('hidden');
  } else {
    $('*[data-index]').last().removeClass('hidden');
    $('div.next-footer-container').removeClass('hidden');
    characteristicsView.indexCounter = 2;
    characteristicsView.dobView = true;
    characteristicsView.dob.init();
    characteristicsView.dob.counter = 3;
    characteristicsView.backBtnHandler();
  }

  $('input[name="user_characteristics_proxy[disabled]"]:radio').on('change', function (event) {
    $.ajax({
      url    : 'header',
      data   : {state: event.currentTarget.id},
      success: function (result) {
        $('#characteristics_header').html(result);
      }
    });
  });
};

/*..............................................................................
 * Characteristics Form View Next Button Handlers
 *.............................................................................*/
characteristicsView.nextBtnHandler = function () {
  //if we're on the last dob form item, switch dobview flag to adv to next
  //characteristic form item
  if (characteristicsView.dob.counter >= characteristicsView.dob.states.DAY) {
    characteristicsView.dobView = false;
  }

  //if we're in the dob section, don't increment the index
  if (characteristicsView.dobView === false) {
    //increment counter
    characteristicsView.indexCounter++;
  }
  else {
    //increment the dob counter
    characteristicsView.dob.counter++;
  }

  //trigger counter change event
  $('#eligibility_form').trigger('indexChange');
};

characteristicsView.backBtnHandler = function (e) {
  if (e && this.indexCounter > 0) e.preventDefault();

  // We've completely backed out of the dob view. if it is down to zero.
  if (this.dob.counter <= 0)
    this.dobView = false;

  //if we're in the dob section, don't increment the index
  if (this.dobView === false) {
    //increment counter
    this.indexCounter--;
  } else {
    //increment the dob counter
    this.dob.counter--;
  }

  //trigger counter change event
  $('#eligibility_form').trigger('indexChange');
};

characteristicsView.dob.setupDays = function () {
  // populate dob days view
  // convert num of days into range array
  // setup initial ul template
  var dayArray = CGUtils.range(1, (this.numberOfDays(this.params.month) + 1))
    , dobDaysTemplate = $('<ul>');

  this.daytable.html('');

  $.each(dayArray, function(index, day) {
    var liElem;
    var numberOfDaysInRow = 8;

    //check if current iteration is last row
    var lastRow = ((index+1) % dayArray.length === 0);

    if (index >= Math.floor(dayArray.length / numberOfDaysInRow) * numberOfDaysInRow) {
      liElem = $('<li>').addClass('bottom').text(day);
    } else {
      liElem = $('<li>').text(day);
    }

    //atached li elem to current ul elem
    dobDaysTemplate.append(liElem);

    if( ((index + 1) % numberOfDaysInRow === 0) || lastRow ) {
      this.daytable.append(dobDaysTemplate);
      //reset ul elem
      dobDaysTemplate = $('<ul>');
    }
  }.bind(this));
};

characteristicsView.dob.init = function () {
  // flag we're in the dob section. This needs to happen
  // every time.
  characteristicsView.dobView = true;

  // don't run this code more than once
  if (this.isIinitialized) return;

  // flag that this code has been executed.
  this.isIinitialized = true;

  // populate years
  characteristicsView.populateYears();

  // get month from previous dob form item or if there was a problem,
  // create the current month
  this.params.month = this.params.month || new Date().getMonth();

  this.setupDays();

  if ($('#user_characteristics_proxy_date_of_birth').val()) {
    var result  = $('#user_characteristics_proxy_date_of_birth').val().split('-')
      , year    = result[0]
      , month   = result[1]
      , day     = result[2];

    try { $('#yeartable  li:contains('+ year  +')').click(); } catch (e) {};
    try { $('#monthtable li:contains('+ month +')').click(); } catch (e) {};
    try { $('#daytable   li:contains('+ day   +')').click(); } catch (e) {};

    // make sure the correct page is visible.
    var page = $('#yearContainer > ul').index($('#yeartable li:contains('+ year +')').closest('ul'));
    characteristicsView.dob.yearpage = page;
    characteristicsView.dob.displayYearPage();
  }
};

/*..............................................................................
 * Characteristics Form View Index Change Handler
 *.............................................................................*/
characteristicsView.indexChangeHandler = function () {
  if (this.indexCounter == 2) {
    $('#left-description h4').text('Tell Us Your Date of Birth')
    $('#left-description p').html('Sharing your birthdate allows us to provide you with the best travel options, including those that may be discounted or only available to seniors.<br><br>Tap "Next Step" when you have selected the correct date.')
  }

  if (this.indexCounter == 1) {
    $('#left-description h4').text('Tell Us More About Yourself')
    $('#left-description p').html('Answer all questions you are comfortable providing an answer for. If you do not wish to answer a question, select "Unsure". Answering these questions will ensure you see personalized travel options.<br><br>Tap "Next Step" when you have finished with these questions.')
  }

  if (this.indexCounter == 0) {
    $('#left-description p').html('Would you be willing to answer a few questions about yourself to determine the best travel options? Questions include date of birth, any mobility challenges and basic demographics. Answering these questions will help us personalize the results you see.<br><br>If you want to see personalized results, tap "Yes". If you tap "No", you will still receive travel options, but they may not be personalized to your needs.')
  }

  //hide everything again
  if (this.indexCounter != this.states.PROGRAMS) {
    this.formItems.addClass('hidden');
  }

  //hide all dob form items
  this.dobItems.addClass('hidden');

  //remove current class from dob breadcrumbs
  this.dob.breadcrumbs.removeClass('current');

  //find element matching current index and dob index
  var matchedElement = $('div[data-index="' + this.indexCounter + '"]');
  var matchedDOBElement = $('div[data-dobindex="' + this.dob.counter + '"]');

  //set current dob breadcrumb
  $(this.dob.breadcrumbs[this.dob.counter]).addClass('current');

  //matched element visible
  matchedElement.removeClass('hidden');
  matchedDOBElement.removeClass('hidden');

  if (this.dobView === false) {
    switch(this.indexCounter) {
      case this.states.YESNO:
        $('div.next-footer-container').addClass('hidden');
        break;

      case this.states.QUESTIONS:
        $('div.next-footer-container').removeClass('hidden');
        break;

      case this.states.DOB:
        this.dob.init();

        //attach template to view
        //this.dob.daytable.append(dobDaysTemplate);
        break;

      case characteristicsView.states.PROGRAMS:
        $('.new_user_characteristics_proxy').submit();
        break;
    }
  }
};

/*..............................................................................
 * DOB Elem Click Handler
 *.............................................................................*/
characteristicsView.handleDobElemClick = function(e) {
  var $target = $(e.target);

  // set dob params on li elem click
  switch ($target.closest('*[data-dobindex]').data('dobindex')) {
    case characteristicsView.dob.states.MONTH:
      characteristicsView.dob.params.month = $target.parent().parent().find('li').index($target);
      break;
    case characteristicsView.dob.states.DAY:
      characteristicsView.dob.params.day = parseInt($target.text());
      break;
    case characteristicsView.dob.states.YEAR:
      characteristicsView.dob.params.year = $target.text();
      break;
  }
};

/*..............................................................................
 * DOB Year Scroller
 *.............................................................................*/
characteristicsView.populateYears = function () {
  var now = new Date();
  var nowYear = now.getUTCFullYear();
  var beginYear = nowYear - 100;
  var yearRange = CGUtils.range(beginYear, nowYear + 1);
  var yearGroups = [];
  var numYearsInGroup = 10;

  //reset yearsPage
  characteristicsView.dob.yearpage = 0;
  //console.log(nowYear, beginYear, yearRange);

  //split year array into groups, groups will be our "pages"
  while (yearRange.length) {
    var group = yearRange.splice(0, numYearsInGroup);
    //add group ("pages") to group array
    yearGroups.push(group);
  }

  //create container div in memory
  var yearContainer = $('<div>').attr('id','yearContainer');

  //loop through all groups
  $.each(yearGroups, function(index, group) {
    //create group markup in memory
    var yearPage = $('<ul>');
    //loop through each group and add the year to the li elem
    $.each(group, function(index, year) {
      //add it our year "page"
      if (index === 8 || index === 9) {
        //we're the last row in the page
        yearPage.append($('<li>').text(year).addClass('bottom'));
      }
      else if (index+1 === group.length) {
        //we have only one year in the page
        yearPage.append($('<li>').text(year).addClass('soloYear'));
      }
      else {
        yearPage.append($('<li>').text(year));
      }
    });

    //add year page to container
    yearContainer.append(yearPage);
  });


  /*..............................................................................
   * Year Pagination Button Events
   *.............................................................................*/

  characteristicsView.dob.displayYearPage = function () {
    var yearPageWidth = this.yearlist.width();
    var leftOffset;

    leftOffset = this.yearpage * yearPageWidth * -1;
    yearContainer.css('left', leftOffset);
  };

  characteristicsView.dob.yearpage = 3;
  characteristicsView.dob.displayYearPage();

  //add whole year container to dom
  $('#yearlist').append(yearContainer);

  $('.next-btn, .prev-btn').on('click', function(e) {
    var $target = $(e.target);

    if ($target.hasClass('next-btn')) {
      //increment page
      characteristicsView.dob.yearpage += 1;
      if (characteristicsView.dob.yearpage > yearGroups.length) {
        characteristicsView.dob.yearpage = yearGroups.length;
      }
    }

    if ($target.hasClass('prev-btn')) {
      characteristicsView.dob.yearpage -= 1;
      if (characteristicsView.dob.yearpage < 0) {
        characteristicsView.dob.yearpage = 0;
      }
    }

    characteristicsView.dob.displayYearPage();
  });
};



///////////////////////////////////////////////////
// DOCUMENT INIT
//
//
///////////////////////////////////////////////////

$(document).ready(function () {
  "use strict";
  var dateSegments = ['year', 'month', 'day'];

  dateSegments.forEach(function (segment, i, arr) {
    $('.js-dob-pickers').on('click', '#'+ segment +'table ul li', function () {
      var dobFirst = $(this)
        , next = arr[arr.indexOf(segment) + 1];

      $('#'+ segment +' ul li').removeClass('selected');

      dobFirst
        .closest('.dob-section').find('li').removeClass('selected').end().end()
        .addClass('selected');

      // month requires extra handling for days in the month
      if (segment == 'month') {
        // first, clear out any previously selected value. This will prevent
        // the 30th from being selected if the user changes the month from June
        // to February.
        $('.dob-breadcrumb li.day span.input').text('');
        $('li.day span.type').removeClass('val-added');
        $('.dob-breadcrumb li.day').removeClass('chosen');

        // clear out / populate the days.
        characteristicsView.dob.setupDays();

        // find the current day and click on it. If the day is not present i.e. a
        // day was selected that is not available for the given month, the value will
        // be reset and no day will be selected.
        var day = characteristicsView.dob.params.day;
        delete characteristicsView.dob.params.day
        try { $('#daytable').find('li:contains('+ day +')').click(); } catch (e) {};
      }

      $('.dob-breadcrumb li.'+ segment +' span.input').text(dobFirst.html());
      $('li.'+ segment +' span.type').addClass('val-added');
      $('.dob-breadcrumb li.'+ segment).addClass('chosen');

      $('#user_characteristics_proxy_date_of_birth').val(
        $('.js-dob-pickers')
          .parent()
          .find('.dob .chosen .input')
          .map(function (i, e) { return $(e).text() })
          .toArray()
          .join('-')
      );
    });
  });

  // kick everything off
  characteristicsView.init();
});

window.CGUtils = {
  // Underscore _.range() method
  // src: http://underscorejs.org/#range
  range: function(start, stop, step) {
    if (arguments.length <= 1) {
      stop = start || 0;
      start = 0;
    }

    step = arguments[2] || 1;

    var length = Math.max(Math.ceil((stop - start) / step), 0);
    var idx = 0;
    var range = new Array(length);

    while(idx < length) {
      range[idx++] = start;
      start += step;
    }

    return range;
  }
}

// -- END DISABLING CODE -- !://
})();
});
