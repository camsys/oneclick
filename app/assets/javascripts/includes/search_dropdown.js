window.scrollContent = function ($, options) {
  $roots = $(options.rootSel);
  if ($roots.length < 1) return;

  var size = options.size;

  function moveSlidesForward  (e) { moveSlides(e, 'forward',  size) }
  function moveSlidesBackward (e) { moveSlides(e, 'backward', size) }

  function moveSlides (e, direction, amount) {
    var $holder     = $(e.delegateTarget)
      , $list       = $holder.find(options.listSel)
      , offset      = $list.data('offset');

    if (direction == 'forward') amount = amount * -1;
    offset = offset + amount;

    changeOffset($holder, offset);
  }

  function changeOffset($holder, offset) {
    $holder.find(options.listSel)
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

  $roots.each(function () {
    var $el = $(this);

    setTimeout(function () {
      checkButtonsEnabled($el, $(this).find(options.listSel).data('offset'));
    }, 50);

    $el.data('scroll-content', {
      refresh: function () {
        checkButtonsEnabled($el, $el.find(options.listSel).data('offset'));
      },
      resetOffset: function () {
        changeOffset($el, 0);
      }
    });
  });
}
