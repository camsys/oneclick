// session based variable storage for UI key/value pairs

// get a key value, if the key does not exist the default value is returned
function get_ui_key_value(key, default_val) {
    var value;
    try {
        value = window.sessionStorage.getItem(key);
    } catch (e) {
        value = default_val;
    }
    //alert('getting value for ' + key + '; val = ' + value);
    return value;
};

// Set a key value. Keys must be unique strings
function set_ui_key_value(key, value) {
    //alert('setting value for ' + key + ' to ' + value);
    window.sessionStorage.setItem(key, value);
};

// Displays an alert
function show_alert(message) {
    $('#messages').html('<div class="alert alert-error fade in"><a class="close" data-dismiss="alert">x</a><div id="flash_notice">' + message + '</div></div>');
}
// Submittal handler for forms sent using ajax
function ajax_submit_form_handler(form_id) {
    var form = $('#' + form_id);
    form.submit(function() {
        $.ajax({
            data: $(this).serialize(),
            type: $(this).attr('method'),
            url: $(this).attr('action'),
            success: function(data) {
                //alert('success');
            },
            error: function(data, textStatus, errorThrown) {
                //alert('error');
                show_alert("We are sorry but something went wrong. Please try again. [3]");
            }
        });
        return false;
    });
};

function ajax_render_action(url, method) {
    $.ajax({
        type: method,
        url: url,
        beforeSend: function() {
            // this is where we append a loading image
            //$('#ajax-panel').html('<div class="loading"><img src="/images/loading.gif" alt="Loading..." /></div>');
        },
        success: function(data) {
            // successful request; do something with the data
            //$('#ajax-panel').empty();
            //$(data).find('item').each(function(i){
            //  $('#ajax-panel').append('<h4>' + $(this).find('title').text() + '</h4><p>' + $(this).find('link').text() + '</p>');
            //});
        },
        error: function(data, textStatus, errorThrown) {
            //alert('error');
            show_alert("We are sorry but something went wrong. Please try again. [4]");
        }
    });
};

// Used to remove any existing banner messages
function remove_messages() {
    $('.alert').alert('close');
};

function nav_to_url(url) {
    document.location.href = url;
}

function click_to_nav(url) {
    alert('Deprecated. Please use event handler!');
    document.location.href = url;
};


// Finds all the class elements on a page and sets the min-height css variable
// to the maximum height of all the containers
function make_same_height(class_name, buffer, max_height) {

    // See if a max height is set
    if (max_height) {
        $(class_name).css('height', max_height);
        return;
    }
    // remove any existing height attributes
    $(class_name).css('height', '');

    // Set the form parts to equal height
    var max = -1;
    $(class_name).each(function() {
        var h = $(this).height();
        max = h > max ? h : max;
    });
    if (buffer) {
        max += buffer;
    }
    //alert("max = " + max);
    $(class_name).css({
        'height': max
    });
};

function fix_thumbnail_margins() {

    $('.thumbnail').removeClass('first-in-row');

    $('.thumbnails').each(function() {
        var $thumbnails = $(this).children();
        var previousOffsetLeft = $thumbnails.first().offset().left;

        $thumbnails.first().addClass('first-in-row');
        $thumbnails.each(function() {
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
    if (OneClick.Config['ui_mode'] != 'kiosk') {
        var i = 0;
        $('.thumbnail').each(function() {
            var remainder = i % counter;
            //alert('i = ' + i + ' remainder = ' + remainder);
            if (remainder == 0) {
                $(this).addClass('first-in-row');
            }
            i++;
        })
    } else {
        // console.log('kiosk')
    }
};