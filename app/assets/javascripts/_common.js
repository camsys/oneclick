
// Used to store markers for address candidates. These need to persist across
// ajax sessions
var address_candidate_markers = new Array();

function clear_candidate_address_markers() {
  for (var i = 0; i < address_candidate_markers.length; i++) {
    removeMarkerFromMap(address_candidate_markers[i]);
  }
  address_candidate_markers = new Array();	
};

function click_to_nav(url) {
  document.location.href = url;
};


// Finds all the class elements on a page and sets the min-height css variable
// to the maximum height of all the containers
function make_same_height(class_name) {

    // remove any existing height attributes
    $(class_name).css('min-height', '');

    // Set the form parts to equal height
    var max = -1;
    $(class_name).each(function() {
        var h = $(this).height();
        max = h > max ? h : max;
    });
    $(class_name).css({'min-height': max});
};

function fix_thumbnail_margins() {

    $('.thumbnail').removeClass('first-in-row');

    $('.thumbnails').each(function () {
        var $thumbnails = $(this).children();
        var previousOffsetLeft = $thumbnails.first().offset().left;

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
    var span_size;
    var counter = 0;
    if (window_width > 1400) {
        span_size = "span3";
        counter = 4;
    } else if (window_width > 979) {
        span_size = "span4";
        counter = 3;
    } else if (window_width > 767) {
        span_size = "span6";
        counter = 2;
    } else {
        span_size = "span12";
        counter = 1;
    }
    //alert('Window = ' + window_width + ' setting icon size to ' + icon_size + ' and span size to ' + span_size);
    $('.trip_summary').removeClass("span12 span6 span4 span3").addClass(span_size);
    $('.thumbnail').removeClass('first-in-row');
    // Add the first-in-row class to the first thumbnail in each row
    var i = 0;
    $('.thumbnail').each(function() {
        var remainder = i % counter;
        //alert('i = ' + i + ' remainder = ' + remainder);
        if (remainder == 0) {
            $(this).addClass('first-in-row');
        }
        i++;
    });
};

