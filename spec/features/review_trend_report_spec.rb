require 'feature_helper'

feature 'Review trend report' do
  context 'When each result has different release date' do
    before(:all) do
      DatabaseCleaner.clean
      @result1 = create(:result, release_date: '01.01.1978 00:00')
      @result2 = create(:result, release_date: '01.01.1978 00:03')
      @result3 = create(:result, release_date: '01.01.1978 00:02')
      @result4 = create(:result, release_date: '01.01.1978 00:04')
      @result5 = create(:result, release_date: '01.01.1978 00:01')
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

  context 'When choosen results are in different projects' do
    before(:all) do
      DatabaseCleaner.clean
      @result1 = create(:result, project_id: 1, release_date: '01.01.1978 00:00')
      @result2 = create(:result, release_date: '01.01.1978 00:01')
      @result3 = create(:result, project_id: 2, release_date: '01.01.1978 00:02')
    end

    scenario 'Redirects to the resutls page and error appears' do
      visit trend_path(result: [@result1.id, @result3.id])

      expect(page).to have_current_path(results_path)
      expect(page).to have_content "Can't create a trend with results in different projects"
    end
  end

  context 'When one of choosen results without release date' do
    before(:all) do
      DatabaseCleaner.clean
      @result1 = create(:result, release_date: '01.01.1978 00:00')
      @result2 = create(:result, release_date: '01.01.1978 00:01')
      @result3 = create(:result, release_date: nil)
    end

    scenario 'Redirects to the resutls page and error appears' do
      visit trend_path(result: [@result1.id, @result3.id])

      expect(page).to have_current_path(results_path)
      expect(page).to have_content "Can't create a trend with results without release date"
    end
  end

  scenario 'Creates a trend only for results in choosen project and with release date' do
    DatabaseCleaner.clean
    result1 = create(:result, project_id: 1, release_date: '01.01.1978 00:00')
    result2 = create(:result, project_id: 1, release_date: nil)
    result3 = create(:result, project_id: 2, release_date: '01.01.1978 00:02')
    result4 = create(:result, project_id: 1, release_date: '01.01.1978 00:03')
    result5 = create(:result, project_id: 1, release_date: '01.01.1978 00:04')

    visit trend_path(result: [result1.id, result5.id])
    ids_diff = page.all('.ids-difference')

    expect(ids_diff.size).to eq(1)
    expect(ids_diff[0].text).to eq([result1.id, result4.id, result5.id].join(', '))
  end

  describe 'Difference table' do
    scenario 'Sorts results ids by release date' do
      DatabaseCleaner.clean
      result1 = create(:result, release_date: '01.01.1978 00:04')
      result2 = create(:result, release_date: '01.01.1978 00:02')
      result3 = create(:result, release_date: '01.01.1978 00:03')
      result4 = create(:result, release_date: '01.01.1978 00:01')
      result5 = create(:result, release_date: '01.01.1978 00:00')

      visit trend_path(result: [result1.id, result5.id])
      ids_diff = page.all('.ids-difference')
      expect(ids_diff.size).to eq(1)
      expect(ids_diff[0].text).to eq([result5.id, result4.id, result2.id, result3.id, result1.id].join(', '))
    end
  end

  scenario 'Click on a Show a label of request shows a plot' do
    DatabaseCleaner.clean
    label = 'login :GET'
    result1 = create(:result, release_date: '01.01.1978 00:01')
    result2 = create(:result, release_date: '01.01.1978 00:02')
    result3 = create(:result, release_date: '01.01.1978 00:03')
    [result1, result2, result3].each do |result|
      create(:calculated_requests_result, result_id: result.id, label: label)
    end

    visit trend_path(result: [result1.id, result3.id])
    show_plot_btn = find('.requests-plot')
    show_plot_btn.click

    within(show_plot_btn['data-target']) do
      expect(page).to have_selector('div.svg-container')
    end
  end
end
