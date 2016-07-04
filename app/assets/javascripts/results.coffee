@handleResultsTable = ->
  setSelectedResultsText = (results) ->
    $('#result-to-compare-list').text("Selected results: #{results.join(', ')}")

  clearSelectedResultsText = ->
    $('#result-to-compare-list').text('')

  setLinks = (results) ->
    resultsUrl = "result[]=#{results[0]}&result[]=#{results[1]}"
    $('#compare-button').attr('href', "/compare?#{resultsUrl}")
    $('#trend-button').attr('href', "/trend?#{resultsUrl}")

  clearLinks = ->
    $('#compare-button').attr('href', '/compare')
    $('#trend-button').attr('href', '/trend')

  checkCheckboxes = (results) ->
    for result in results
      $("input[type=checkbox][value=#{result}]").prop('checked', true)

  uncheckCheckboxes = ->
    $('.result-checkbox').prop('checked', false)

  showClearBtn = ->
    $('#clear-results').show()

  hideClearBtn = ->
    $('#clear-results').hide()

  getResults = ->
    Cookies.getJSON('results')

  setResults = (results) ->
    Cookies.set('results', results)

  clearResults = ->
    Cookies.remove('results')

  toggleCheckbox = (checkbox) ->
    checkbox.prop('checked', not checkbox.is(':checked'))

  $('#results-table > tbody > tr').click (event) ->
    return if event.target.className.match(/glyphicon/)

    checkbox = $(':checkbox', this)
    if event.target.type isnt 'checkbox'
      toggleCheckbox(checkbox)
    clickedResult = checkbox.attr("value")

    results = getResults()
    results ?= []
    if clickedResult in results
      results = (e for e in results when e isnt clickedResult)
    else
      results.push clickedResult
    setResults(results)

    if results.length
      showClearBtn()
      setSelectedResultsText(results)
      if results.length > 1 then setLinks(results) else clearLinks()
    else
      hideClearBtn()
      clearSelectedResultsText()
      clearLinks()

  #
  # $(".result-checkbox").attr("disabled", true)
  # toggleRequest() unless checkbox.is(":disabled")

  $('#clear-results').click ->
    hideClearBtn()
    clearResults()
    clearSelectedResultsText()
    clearLinks()
    uncheckCheckboxes()

  $('#compare-button').click ->
    if getResults().length > 1
      clearResults()

  $('#trend-button').click ->
    if getResults().length > 1
      clearResults()

  initialize = ->
    results = getResults()
    unless results?
      uncheckCheckboxes()
      return

    showClearBtn()
    checkCheckboxes(results)
    setSelectedResultsText(results)
    setLinks(results)

  initialize()

saveFiles = ->
  $('#edit_requests_data').click ->
    $('#upload_requests_data').toggleClass('hidden')
    $('#download_requests_data').addClass('hidden')

  $('#edit_performance_data').click ->
    $('#upload_performance_data').toggleClass('hidden')
    $('#download_performance_data').addClass('hidden')

ready = ->
  handleResultsTable()
  saveFiles()

$(document).ready(ready)
$(document).on('page:load', ready)
