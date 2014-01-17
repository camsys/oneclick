window.scrollContent = function ($, options) {
  $roots = $(options.rootSel);
  if ($roots.length < 1) return;

  var size = options.size;

  function moveSlidesForward  (e) { moveSlides(e, 'forward',  size) }
  function moveSlidesBackward (e) { moveSlides(e, 'backward', size) }

  function moveSlides (e, direction, amount) {
    var $holder     = $(e.delegateTarget)
      , $nextButton = $(e.target)
      , $list       = $holder.find(options.listSel)
      , offset      = $list.data('offset');

    if (direction == 'forward') amount = amount * -1;
    offset = offset + amount;


    $list
      .data('offset',        offset)
      .css(options.property, offset + 'px');

    checkButtonsEnabled($holder, offset);
  }

  function checkButtonsEnabled ($holder, offset) {
    var steps = offset / size;

    if (steps <= 0 && Math.abs(offset - size) >= options.total($holder)) {
      $holder.find('.js-next-btn').addClass('disabled');
    } else {
      $holder.find('.js-next-btn').removeClass('disabled');
    }

    if (steps >= 0) {
      $holder.find('.js-prev-btn').addClass('disabled');
    } else {
      $holder.find('.js-prev-btn').removeClass('disabled');
    }
  }

  $roots.on('click', '.js-next-btn:not(.disabled)', moveSlidesForward);
  $roots.on('click', '.js-prev-btn:not(.disabled)', moveSlidesBackward);

  $roots.each (function () {
    $el = $(this);
    setTimeout(function () {
      checkButtonsEnabled($el, $(this).find(options.listSel).data('offset'));
    }, 50);
  });
}
