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

// Finds all the class elements on a page and sets the min-height css variable
// to the maximum height of all the containers
function make_same_height(class_name) {

	// Set the form parts to equal height
	var max = -1;
	$(class_name).each(function() {
		var h = $(this).height(); 
		max = h > max ? h : max;
	});
	$(class_name).css({'min-height': max});	
};
function fix_thumbnail_margins() {
	
    $('.row-fluid .thumbnails').each(function () {
        var $thumbnails = $(this).children();
        var previousOffsetLeft = $thumbnails.first().offset().left;
        
        //alert(previousOffsetLeft);
        
        $thumbnails.removeClass('first-in-row');
        $thumbnails.first().addClass('first-in-row');
        $thumbnails.each(function () {
            var $thumbnail = $(this);
            var offsetLeft = $thumbnail.offset().left;
            //alert('prev = ' + previousOffsetLeft + ' offset = ' + offsetLeft);
            if (offsetLeft < previousOffsetLeft) {
                $thumbnail.addClass('first-in-row');
                //alert('added class');
            }
            previousOffsetLeft = offsetLeft;
        });
    });
};
