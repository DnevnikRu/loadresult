ready = ->
  $('#results-table tr').click (event) ->
    if event.target.type isnt 'checkbox'
      $(':checkbox', this).trigger 'click'

$(document).ready(ready)
$(document).on('page:load', ready)
