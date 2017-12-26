focusAnchor = ->
  $('.focused-result').removeClass('focused-result')
  anchorId = $(location).attr('hash')
  $(anchorId).parent().parent().addClass('focused-result')

hideColumns = ->
  request_table = $('div#collapseRequestsData')
  request_table.find('.line90').hide()
  request_table.find('.min').hide()
  request_table.find('.max').hide()
  request_table.find('.throughput').hide()
  request_table.find('.failed_request').hide()
  $('td.trend').each (i, n) ->
    if $(n).text() < -15
      $(n).css 'background-color', '#DFF5DF'
    if $(n).text() > 15
      $(n).css 'background-color', '#F5E0DF'
    return
  return

stickyHeader = ->
  $('.sticky-header').stickyTableHeaders cacheHeaderHeight: true
  return

tooltip = ->
  $('[data-toggle="tooltip"]').tooltip
    'delay':
      show: 1200
      hide: 20
    container: 'body'
    placement: 'bottom'
    html: true
  return

ready = ->
  focusAnchor()
  hideColumns()
  stickyHeader()
  tooltip()

$(document).ready(ready)
$(document).on('page:load', ready)
$(window).on('hashchange', focusAnchor)

@showColumn = (btn_name, column) ->
  btn = document.getElementById(btn_name)
  request_table = $('div#collapseRequestsData')
  if btn.checked
    request_table.find('.' + column).show()
  else
    request_table.find('.' + column).hide()
  return