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
  $(".label-help").tooltip({'html': true, 'container': 'body', 'trigger': 'hover focus'});
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
  $(label_id).prepend("<i class='fa fa-question-circle pull-right label-help' style='margin-top:-4px;' title data-original-title='" + tooltip_str + "' aria-label='" + tooltip_str + "' tabindex='0'></i>");
}

