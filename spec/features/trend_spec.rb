require 'feature_helper'

feature 'Review trend report' do
  before(:all) do
    @result1 = create(:result, test_run_date: '01.01.1978 00:00')
    @result2 = create(:result, test_run_date: '01.01.1978 00:03')
    @result3 = create(:result, test_run_date: '01.01.1978 00:02')
    @result4 = create(:result, test_run_date: '01.01.1978 00:04')
    @result5 = create(:result, test_run_date: '01.01.1978 00:01')
  end

  scenario 'Redirects to the resutls page if there is one id' do
    visit trend_path(result: [@result1.id])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content 'You should select 2 results to create a trend'
  end

  scenario 'Redirects to the resutls page if there are no ids' do
    visit trend_path(result: [])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content 'You should select 2 results to create a trend'
  end

  scenario 'Redirects to the resutls page if ids are absent' do
    visit trend_path(result: [999_998, 999_999])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content "Can't find selected results"
  end

  scenario 'Redirects to the resutls page if one id is absent' do
    visit trend_path(result: [@result1.id, 999_999])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content "Can't find selected results"
  end

  scenario 'Redirects to the resutls page if there are only two results between selected results' do
    visit trend_path(result: [@result2.id, @result4.id])
    expect(page).to have_current_path(results_path)
    expect(page).to have_content "There are only 2 results between selected results. Can't create a trend"

    visit trend_path(result: [@result4.id, @result2.id])
    expect(page).to have_current_path(results_path)
    expect(page).to have_content "There are only 2 results between selected results. Can't create a trend"
  end

  scenario 'Opens Trend page if there are 3 or more results between selected results' do
    visit trend_path(result: [@result2.id, @result5.id])
    expect(find('h1')).to have_content('Trend')

    visit trend_path(result: [@result5.id, @result2.id])
    expect(find('h1')).to have_content('Trend')

    visit trend_path(result: [@result1.id, @result4.id])
    expect(find('h1')).to have_content('Trend')
  end
end
