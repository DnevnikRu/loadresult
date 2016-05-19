ready = ->
  $('.datetimepicker2').datetimepicker locale: 'ru'

$(document).ready(ready)
$(document).on('page:load', ready)