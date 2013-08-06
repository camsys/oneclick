$(document).ready(function() {
    fix_thumbnails();
});
$(window).resize(function() {
    fix_thumbnails();
});
function fix_thumbnails() {
    // remove any height attributes
    $(".thumbnail").css('height', '');
    $(".thumbnail").css('overflow', '');
    var window_width = $(window).width();
    adjust_thumbnails(window_width);
};
make_same_height('.thumbnail');

$("#itineraries").on("ajax:success", function(event,data){
    $("#itinerary" + data['id']).hide()
    fix_thumbnails();
    fix_thumbnail_margins();
})

$("#itineraries").on("ajax:error", function(xhr,status){
    alert(status['responseText']);
})
