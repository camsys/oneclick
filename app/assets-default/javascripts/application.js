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
      'placement': 'top',
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
  })
  .on("mousemove", function (e) {
    if ($(this).hasClass('single-plan-chart-container')) {
      var left = e.pageX;
      var rectOffset = $(this).children().children('rect:first').offset();
      var leftBoundary = rectOffset.left;
      var rightBoundary = $(this).children().children('rect:last').offset().left + parseInt($(this).children().children('rect:last').attr('width'));
      var popoverWidth = $(".popover").width();
      var popoverHeight = $(".popover").height();

      $(".popover").css({
        top: rectOffset.top - popoverHeight,
        left: (left < leftBoundary ?
          ( $(".popover").css({ left: leftBoundary - popoverWidth / 2 + 'px' }) ) :
          ( left > rightBoundary ? 
            ( $(".popover").css({ left: rightBoundary - popoverWidth / 2 + 'px' }) ) :
            ( left - popoverWidth / 2 + 'px' ) ))
      });
    }
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


