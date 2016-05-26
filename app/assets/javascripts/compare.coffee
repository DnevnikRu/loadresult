focusAnchor = ->
  $('.focused-result').removeClass('focused-result')
  anchorId = $(location).attr('hash')
  $(anchorId).parent().parent().addClass('focused-result')

ready = ->
  focusAnchor()

$(document).ready(ready)
$(document).on('page:load', ready)
$(window).on('hashchange', focusAnchor)