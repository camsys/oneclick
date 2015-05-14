// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require bootstrap
//= require handlebars
//= require twitter/typeahead
//= require moment
//= require bootstrap-datetimepicker
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require leaflet
//= require_tree .
//

$(document).ready(function(){
  createPopover(".label-help");
});

moment.fn.next15 = function() {
    var intervals = Math.floor(this.minutes() / 15);
    if (this.minutes() % 15 != 0)
        intervals++;
    if (intervals == 4) {
        this.add('hours', 1);
        intervals = 0;
    }
    this.minutes(intervals * 15);
    this.seconds(0);
    return this;
}

function checkAriaLabel(input){
    if (input.attr('disabled') == 'disabled' || input.hasClass('disabled')){
        input.children().attr('aria-label', 'disabled. ');
    } else {
        input.children().removeAttr('aria-label');
    }
}

function toggleAriaLabel(input) {
    input.attrchange({
      trackValues: true,
      callback: function(e) {
        if ($(this).attr('disabled') == undefined) {
          $(this).children().removeAttr('aria-label');
        } else {
          $(this).children().attr('aria-label', 'disabled. ');
        }
      }
    });
}

function toggleAriaLabelPrevNext(input) {
    input.attrchange({
      trackValues: true,
      callback: function(e) {
        if (e.newValue.indexOf("disabled") > -1) {
            $(this).children().attr('aria-label', 'disabled. ');
        } else {
            $(this).children().removeAttr('aria-label');
        }
      }
    });    
}

function addHelperTooltip(label_id, tooltip_str) {
  $(label_id).append("<i class='fa fa-question-circle pull-right label-help' style='margin-top:-4px;' title data-original-title='" + tooltip_str + "' aria-label='" + tooltip_str + "' tabindex='0'></i>");
}

function createPopover(node_id) {
  $(node_id).popover({
      'html': true,
      'container': 'body',
      'template': '<div class="popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>',
      'trigger': 'manual focus',
      'animation': false,
      'placement': 'auto',
      content: function() {
          html = $(this).attr('data-original-title');
          return $.parseHTML(html);
      }
  })
  .on("show.bs.popover", function () {
    $(node_id).not(this).popover('hide');
  })
  .on("mouseenter", function () {
    var _this = this;
    $(this).popover("show");
    $(".popover").on("mouseleave", function () {
        $(_this).popover('hide');
    });
  })
  .on("mouseleave", function () {
    var _this = this;
    setTimeout(function () {
        if (!$(".popover:hover").length) {
            $(_this).popover("hide");
        }
    }, 0);
  });
}

function differentiateTurnByTurn(click) {
  $('.drivingDirectionsLink').each(function(index){
    parentDiv = $(this).parent();
    parentDivTarget = parentDiv.attr('data-target');
    parentDiv.attr('data-target', parentDivTarget + index);
    dataTarget = parentDiv.siblings('#drivingDirections').attr('id');
    parentDiv.siblings('#drivingDirections').attr('id', dataTarget + index);

    if (click == "true") {
      $(this).click();
    }
  });
}

function isMobile() {
  if(/mobile|android|touch|webos|hpwos/i.test(navigator.userAgent.toLowerCase())) {
    return true;
  } else {
    return false;
  }
}

String.prototype.titleize = function() {
  var words = this.split(' ')
  var array = []
  for (var i=0; i<words.length; ++i) {
    array.push(words[i].charAt(0).toUpperCase() + words[i].toLowerCase().slice(1))
  }
  return array.join(' ')
}

// initialize a place picker to query 1-click place datatable and google places
function init_place_picker(dom_selector, query_bounds, query_restrictions) {
  var saved_places = new Bloodhound({
    datumTokenizer: function(d) {
     return  Bloodhound.tokenizers.whitespace(d.value);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: '/place_search.json?no_map_partial=true',
      rateLimitWait: 600,
      replace: function(url, query) {
        url = url + '&query=' + query;
        return url;
      }
    },
    limit: 10
  });

  saved_places.initialize()

  var autocomplete_service_config = {};
  if (query_bounds) 
    autocomplete_service_config.bounds = new google.maps.LatLngBounds(
      new google.maps.LatLng(query_bounds.xmin,query_bounds.ymin), 
      new google.maps.LatLng(query_bounds.xmax,query_bounds.ymax));
  if (query_restrictions)
    autocomplete_service_config.componentRestrictions = query_restrictions;
  var google_place_picker = new AddressPicker({
    autocompleteService: autocomplete_service_config
  });

  $(dom_selector).typeahead(null,
    {
      displayKey: "name",
      source: saved_places.ttAdapter(),
      templates: {
        suggestion: Handlebars.compile([
          '<a>{{name}}</a>'
        ].join(''))
      }
    },
    {
      displayKey: "description",
      source: google_place_picker.ttAdapter(),
      templates: {
        suggestion: Handlebars.compile([
          '<a>{{description}}</a>'
        ].join(''))
      }
    });
}

function toggleServiceProfilePanels(obj, transit_id, taxi_id) {
  hideFromTransit = $("#schedule-panel, #advanced-notice-panel, #accommodations-panel, #eligibility-panel, #trip-purposes-panel, #fare-panel, #coverage-areas-panel, #time-and-booking-panels");
  hideFromTaxi = $("#advanced-notice-panel, #eligibility-panel, #trip-purposes-panel, #time-and-booking-panels");

  if ( obj == transit_id ) {
    hideFromTransit.hide();
  } else {
    hideFromTransit.show();
    if ( obj == taxi_id ) {
      hideFromTaxi.hide();
      $('#fare-panel').insertAfter('#accommodations-panel');
      $('#fare-panel .panel-default').css('height', $('#accommodations-panel .panel-default').css('height'));
    } else {
      $('#fare-panel').insertAfter('#trip-purposes-panel');
      hideFromTaxi.show();
      $('#fare-panel .panel-default').css('height', $('#eligibility-panel .panel-default').css('height'));
    } 
  }
}
