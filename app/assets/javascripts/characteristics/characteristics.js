jQuery(function ($) {
(function () {
if ($('.js-trip-wizard-form').length > 0) return;
// -- END START OF DISABLING CODE -- !://

/**
 * Created by Miguel Bermudez on 12/9/13.
 */

var dobFirst;
var characteristicsView = {
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
  this.dobItems = $('.dob-section', '#new_user_characteristics_proxy');
  this.dob = {
    counter: 0,
    states: {
      MONTH: 0,
      DAY: 1,
      YEAR: 2
    },
    yearpage: 0,
    params: {},
    breadcrumbs: $('.dob-breadcrumb li'),
    monthtable: $('#monthtable'),
    daytable: $('#daytable'),
    yeartable: $('#yeartable'),
    yearlist: $('#yearlist'),

    //get number of days for a particular month, months are 0 based
    numberOfDays: function(month) {
      var now = new Date();
      var m = month + 1;
      var d = new Date(now.getUTCFullYear(), m, 0);
      return d.getDate();
    }
  };

  //add indexChange handler to form
  $('#eligibility_form').on('indexChange', characteristicsView.indexChangeHandler.bind(characteristicsView));

  //add click handler to next button
  $('.next-step-btn, a#yes').on('click', characteristicsView.nextBtnHandler.bind(characteristicsView));

  $('.back-button a').on('click', characteristicsView.backBtnHandler.bind(characteristicsView));

  //add click handlers to dob form li elements (table)
  characteristicsView.dobItems.find('li').on('click', characteristicsView.handleDobElemClick.bind(characteristicsView));

  //reveal first form item
  if (true) {
    $('*[data-index=0]').removeClass('hidden');
  } else {
    $('*[data-index]').last().removeClass('hidden');
    $('div.next-footer-container').removeClass('hidden');
    characteristicsView.indexCounter = 2;
    characteristicsView.dobView = true;
    characteristicsView.initDOB();
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
  if (characteristicsView.dob.counter >= characteristicsView.dob.states.YEAR) {
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

  if (characteristicsView.indexCounter == 2) {
    $('#left-description h4').text('Tell Us Your Date of Birth')
    $('#left-description p').html('Sharing your birthdate allows us to provide you with the best travel options, including those that may be discounted or only available to seniors.<br><br>Tap "Next Step" when you have selected the correct date.')
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

  if (this.indexCounter == 2) {
    $('#left-description h4').text('Tell Us Your Date of Birth')
    $('#left-description p').html('Sharing your birthdate allows us to provide you with the best travel options, including those that may be discounted or only available to seniors.<br><br>Tap "Next Step" when you have selected the correct date.')
  }

  //trigger counter change event
  $('#eligibility_form').trigger('indexChange');
};

characteristicsView.initDOB = function () {
  // populate years
  this.populateYears();

  // get month from previous dob form item or if there was a problem,
  // create the current month
  this.dob.params.month = this.dob.params.month || new Date().getMonth();
  var month = this.dob.params.month;

  //setup initial ul template
  var dobDaysTemplate = $('<ul>');

  //flag we're in the dob section
  this.dobView = true;

  //populate dob days view
  //  convert num of days into range array
  var dayArray = CGUtils.range( 1, (this.dob.numberOfDays(month) + 1) );

  $.each(dayArray, function(index, day) {
    var liElem;
    var numberOfDaysInRow = 8;

    //check if current iteration is last row
    var lastRow = ((index+1) % dayArray.length === 0);

    if ( index >= Math.floor(dayArray.length/numberOfDaysInRow) * numberOfDaysInRow) {
      liElem = $('<li>').addClass('bottom').text(day);
    } else {
      liElem = $('<li>').text(day);
    }

    //atached li elem to current ul elem
    dobDaysTemplate.append(liElem);

    if( ((index+1) % numberOfDaysInRow === 0) || lastRow ) {
      this.dob.daytable.append(dobDaysTemplate);
      //reset ul elem
      dobDaysTemplate = $('<ul>');
    }
  }.bind(this));
}

/*..............................................................................
 * Characteristics Form View Index Change Handler
 *.............................................................................*/
characteristicsView.indexChangeHandler = function () {
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
      case this.states.QUESTIONS:
        $('div.next-footer-container').removeClass('hidden');
        break;

      case this.states.DOB:
        this.initDOB();

        //attach template to view
        //this.dob.daytable.append(dobDaysTemplate);
        break;

      case characteristicsView.states.PROGRAMS:
        $('#new_user_characteristics_proxy').submit();
        break;
    }
  }
};

/*..............................................................................
 * DOB Elem Click Handler
 *.............................................................................*/
characteristicsView.handleDobElemClick = function(e) {
  var $target = $(e.target);
  var value = $target.val();

  //set dob params on li elem click
  switch ($target.attr('data-dobindex')) {
    case characteristicsView.dob.states.MONTH:
      characteristicsView.dob.params.month = value;
      break;
    case characteristicsView.dob.states.DAY:
      characteristicsView.dob.params.day = value;
      break;
    case characteristicsView.dob.states.YEAR:
      characteristicsView.dob.params.year = value;
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

      if (typeof next != 'undefined') {
        // $('#'+ segment +'table').fadeOut(function () {
        //   $('#'+ next +'table').fadeIn().removeClass('hidden');
        //   $('.dob-breadcrumb li.'+ segment).removeClass('current');
        //   $('.dob-breadcrumb li.'+ next).addClass('current');
        // });
      } else {
      }
    });
  });

  //kick everything off
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
