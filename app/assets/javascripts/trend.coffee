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

  $('input[name=trend-performance-label]:radio').change (event) ->
    idFrom = $('#id-from').val();
    idTo = $('#id-to').val();
    group_name = $(@).val();
    $.ajax({
      url: '/trend/performance_plot'
      type: 'POST'
      data: "group_name=#{group_name}&id_from=#{idFrom}&id_to=#{idTo}"
      dataType: 'script'
    })

$(document).ready(ready)
$(document).on('page:load', ready)
