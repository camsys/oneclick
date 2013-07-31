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
//= require bootstrap-typeahead
//= require bootstrap-combobox
//= require_tree .

function fix_thumbnail_margins() {
	
    $('.thumbnails').each(function () {
        var $thumbnails = $(this).children();
        var previousOffsetLeft = $thumbnails.first().offset().left;
        
        $thumbnails.removeClass('first-in-row');
        $thumbnails.first().addClass('first-in-row');
        $thumbnails.each(function () {
            var $thumbnail = $(this);
            var offsetLeft = $thumbnail.offset().left;
            if (offsetLeft < previousOffsetLeft) {
                $thumbnail.addClass('first-in-row');
            }
            previousOffsetLeft = offsetLeft;
        });
    });
};
function get_viewport_width() {
	var x = 0;
    if (self.innerHeight) {
		x = self.innerWidth;
    } else if (document.documentElement && document.documentElement.clientHeight) {
        x = document.documentElement.clientWidth;
    } else if (document.body) {
       	x = document.body.clientWidth;
    }
    return x;
};
function adjust_thumbnails(window_width) {
	var icon_size;
	var span_size;
	if (window_width > 1200) {
		icon_size = "5em";
		span_size = "span3";
	} else if (window_width > 979) {
		icon_size = "5em";
		span_size = "span4";
	} else if (window_width > 767) {
		icon_size = "3em";
		span_size = "span6";
	} else {
		icon_size = "4em";
		span_size = "span12";
	}
	//alert("setting icon size to " + icon_size + ' and span size to ' + span_size);
	$('.mode_icon_formatting').css("font-size", icon_size);
	$('.trip_summary').removeClass("span12 span6 span4 span3").addClass(span_size)
};

