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
        complete: ->
          $(".result-checkbox").removeAttr("disabled")
      })
    toggleRequest() unless checkbox.is(":disabled")

  $('#edit_requests_data').click ->
    $('#upload_requests_data').toggleClass('hidden')
    $('#download_requests_data').addClass('hidden')

  $('#edit_performance_data').click ->
    $('#upload_performance_data').toggleClass('hidden')
    $('#download_performance_data').addClass('hidden')

$(document).ready(ready)
$(document).on('page:load', ready)
