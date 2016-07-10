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

  disableOtherResults = (selectedResults) ->
    for result in $(".result-checkbox")
      unless result.value in selectedResults
        $("input[type=checkbox][value=#{result.value}]").attr('disabled', true)

  enableResults = ->
    $(".result-checkbox").attr('disabled', false)

  checkCheckboxes = (results) ->
    for result in results
      $("input[type=checkbox][value=#{result}]").prop('checked', true)

  uncheckCheckboxes = ->
    $('.result-checkbox').prop('checked', false)

  showClearBtn = ->
    $('#clear-results').show()

  hideClearBtn = ->
    $('#clear-results').hide()

  getSavedResuls = ->
    Cookies.getJSON('results')

  saveResults = (results) ->
    Cookies.set('results', results)

  clearResults = ->
    Cookies.remove('results')

  toggleCheckbox = (checkbox) ->
    checkbox.prop('checked', not checkbox.is(':checked'))

  $('#results-table > tbody > tr').click (event) ->
    return if event.target.className.match(/glyphicon/)

    checkbox = $(':checkbox', this)
    clickedResult = checkbox.attr('value')

    results = getSavedResuls()
    results ?= []
    if clickedResult in results
      # remove the clicked result from the saved results
      results = (e for e in results when e isnt clickedResult)
    else
      return if results.length is 2
      results.push clickedResult

    if event.target.type isnt 'checkbox'
      toggleCheckbox(checkbox)
    if results.length
      setSelectedResultsText(results)
      showClearBtn()
      if results.length < 2
        clearLinks()
        enableResults()
      else if results.length is 2
        setLinks(results)
        disableOtherResults(results)
    else
      hideClearBtn()
      clearSelectedResultsText()
      clearLinks()

    saveResults(results)

  $('#clear-results').click ->
    hideClearBtn()
    clearResults()
    clearSelectedResultsText()
    clearLinks()
    uncheckCheckboxes()
    enableResults()

  $('#compare-button').click ->
    clearResults() if getSavedResuls().length > 1

  $('#trend-button').click ->
    clearResults() if getSavedResuls().length > 1

  initialize = ->
    results = getSavedResuls()
    unless results?
      uncheckCheckboxes()
      return

    showClearBtn()
    checkCheckboxes(results)
    setSelectedResultsText(results)
    setLinks(results)
    disableOtherResults(results) if results.length == 2

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

