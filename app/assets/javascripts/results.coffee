ready = ->
  $('#results-table tr').click (event) ->
    return if event.target.className.match(/glyphicon/)
    checkbox = $(':checkbox', this)
    checkbox.trigger 'click' if event.target.type isnt 'checkbox'
    resultId = checkbox.attr("value")
    toggleRequest = ->
      $(".result-checkbox").attr("disabled", true)
      $("#compare-button").removeAttr("href")
      $.ajax({
        url: "/results/#{resultId}/toggle"
        type: 'PUT'
        dataType: 'script'
        success: (data) ->
          $(".result-checkbox").removeAttr("disabled")
      })
    toggleRequest() unless checkbox.is(":disabled")

$(document).ready(ready)
$(document).on('page:load', ready)
