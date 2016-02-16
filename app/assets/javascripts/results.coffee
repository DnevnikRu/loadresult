$(document).on 'ready page:change', ->
  $('#results-table tr').click (event) ->
    if event.target.type isnt 'checkbox'
      $(':checkbox', this).trigger 'click'
