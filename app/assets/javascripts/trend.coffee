ready = ->
  $('input[name=trend-request-label]:radio').change (event) ->
    idFrom = $('#id-from').val();
    idTo = $('#id-to').val();
    label = $(@).val();
    $.ajax({
      url: '/trend/requests_plot'
      type: 'POST'
      data: "label=#{label}&id_from=#{idFrom}&id_to=#{idTo}"
      dataType: 'script'
    })

$(document).ready(ready)
$(document).on('page:load', ready)
