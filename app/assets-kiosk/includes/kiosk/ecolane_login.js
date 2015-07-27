jQuery(function ($) {
    if (!$('form').hasClass('js-ecolane-login-form')) return;

    var countypicker = $('#countypicker');

    countypicker.find('ul li').on('click', function () {
        var el = $(this)
          , county = el.text();

        // Part 1
        if (el.hasClass('selected')) {
            // if class already exists on THIS li
            // do nothing
        } else {
            countypicker.find('ul li').removeClass('selected');
            el.addClass('selected');
            countypicker.find('input').val(county.trim());
        }
    });
});
