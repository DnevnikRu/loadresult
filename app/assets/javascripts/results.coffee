ready = ->
  $('#results-table tr').click (event) ->
    if event.target.type isnt 'checkbox' and not event.target.className.match(/glyphicon/)
      $(':checkbox', this).trigger 'click'

$(document).ready(ready)
$(document).on('page:load', ready)
