ready = ->
  $('#results-table tr').click (event) ->
    if event.target.type isnt 'checkbox' and not event.target.className.match(/glyphicon/)
      $(':checkbox', this).trigger 'click'
      checkbox_value = $(':checkbox', this).attr("value")
      $.ajax
        url: "results/#{checkbox_value}/toggle"
        type: 'PUT'
        dataType: 'json'
#        async: false
        success: (responseText) ->
          ????



$(document).ready(ready)
$(document).on('page:load', ready)
