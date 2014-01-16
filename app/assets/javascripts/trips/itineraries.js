jQuery(function ($) {
  $itineraries = $('.js-trip-itineraries-slides')
  if ($itineraries.length < 1) return;

  var width = 18 + 321 + 1;

  function moveSlidesForward  (e) { moveSlides(e, 'forward',  width) }
  function moveSlidesBackward (e) { moveSlides(e, 'backward', width) }

  function moveSlides (e, direction, amount) {
    var $holder     = $(e.delegateTarget)
      , $nextButton = $(e.target)
      , $thumbnails = $holder.find('.thumbnails')
      , offset      = $thumbnails.data('offset');

    if (direction == 'forward') amount = amount * -1;
    offset = offset + amount;

    $thumbnails
      .data('offset',     offset)
      .css('margin-left', offset + 'px');

    checkButtonsEnabled($holder, offset);
  }

  function checkButtonsEnabled ($holder, offset) {
    var steps = offset / width
      , total = $holder.find('.thumbnail').length;

    console.log(steps);
    console.log($holder.find('.thumbnail').length);

    if (steps <= 0 && steps + total <= 3) {
      $holder.find('.next-btn').addClass('disabled');
    } else {
      $holder.find('.next-btn').removeClass('disabled');
    }

    if (steps >= 0) {
      $holder.find('.prev-btn').addClass('disabled');
    } else {
      $holder.find('.prev-btn').removeClass('disabled');
    }
  }

  $itineraries.on('click', '.next-btn:not(.disabled)', moveSlidesForward);
  $itineraries.on('click', '.prev-btn:not(.disabled)', moveSlidesBackward);

  $itineraries.each (function () {
    checkButtonsEnabled($(this), $(this).find('.thumbnails').data('offset'));
  });
});
