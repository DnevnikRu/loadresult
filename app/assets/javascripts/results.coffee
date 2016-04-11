ready = ->
  $('#results-table tr').click (event) ->
    if event.target.type isnt 'checkbox' and not event.target.className.match(/glyphicon/)
      $(':checkbox', this).trigger 'click'

  $('#edit_requests_data').click ->
    $('#upload_requests_data').toggleClass('hidden')
    $('#download_requests_data').addClass('hidden')

$(document).ready(ready)
$(document).on('page:load', ready)
