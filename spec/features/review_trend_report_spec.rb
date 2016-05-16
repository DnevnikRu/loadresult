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

  context 'Colors of trend percent in labels' do
    before(:all) do
      DatabaseCleaner.clean
      @result1 = create(:result, release_date: '01.01.1978 00:00')
      @result2 = create(:result, release_date: '01.01.1978 00:01')
      @result3 = create(:result, release_date: '01.01.1978 00:02')
      @result4 = create(:result, release_date: '01.01.1978 00:03')
      @result5 = create(:result, release_date: '01.01.1978 00:04')

      create(
          :calculated_requests_result,
          result_id: @result1.id,
          label: 'GET:TEST',
          mean: 10,
          median: 20,
          ninety_percentile: 30,
          throughput: 40
      )
      create(
          :calculated_requests_result,
          result_id: @result1.id,
          label: 'ROOT:TEST',
          mean: 100,
          median: 200,
          ninety_percentile: 300,
          throughput: 400
      )
      create(
          :calculated_requests_result,
          result_id: @result1.id,
          label: 'POST:TEST',
          mean: 100,
          median: 200,
          ninety_percentile: 300,
          throughput: 400
      )
      create(
          :calculated_requests_result,
          result_id: @result5.id,
          label: 'GET:TEST',
          mean: 1,
          median: 2,
          ninety_percentile: 3,
          throughput: 4
      )
      create(
          :calculated_requests_result,
          result_id: @result5.id,
          label: 'ROOT:TEST',
          mean: 1000,
          median: 2000,
          ninety_percentile: 3000,
          throughput: 4000
      )
      create(
          :calculated_requests_result,
          result_id: @result5.id,
          label: 'POST:TEST',
          mean: 102,
          median: 202,
          ninety_percentile: 302,
          throughput: 402
      )
    end

    scenario 'Red color when trend is bigger than 15' do
      visit trend_path(result: [@result1.id, @result5.id])
      expect(find(:xpath, "//span[@class='percent_for_ROOT:TEST']")[:style]).to eql('color: rgb(216, 15, 10);')
    end

    scenario 'Green color when trend is less than -15' do
      visit trend_path(result: [@result1.id, @result5.id])
      expect(find(:xpath, "//span[@class='percent_for_GET:TEST']")[:style]).to eql('color: rgb(21, 169, 24);')
    end

    scenario 'Black color when trend is between -15 and 15' do
      visit trend_path(result: [@result1.id, @result5.id])
      expect(find(:xpath, "//span[@class='percent_for_POST:TEST']")[:style]).to eql('color: rgb(51, 51, 51);')
    end
  end

  context 'Request plot' do
    scenario 'Click on a label of request shows a plot' do
      DatabaseCleaner.clean
      label = 'login :GET'
      result1 = create(:result, release_date: '01.01.1978 00:01')
      result2 = create(:result, release_date: '01.01.1978 00:02')
      result3 = create(:result, release_date: '01.01.1978 00:03')
      [result1, result2, result3].each do |result|
        create(:calculated_requests_result, result_id: result.id, label: label)
      end

      visit trend_path(result: [result1.id, result3.id])
      show_plot_btn = find('.trend-request-plot-button')
      show_plot_btn.click

      within('#trend-requests-plot') do
        expect(page).to have_selector('div.svg-container')
      end
    end

    scenario 'Click on a label of request shows a plot even if one result does not have the label' do
      DatabaseCleaner.clean
      label = 'login :GET'
      result1 = create(:result, release_date: '01.01.1978 00:01')
      result2 = create(:result, release_date: '01.01.1978 00:02')
      result3 = create(:result, release_date: '01.01.1978 00:03')
      [result1, result3].each do |result|
        create(:calculated_requests_result, result_id: result.id, label: label)
      end

      visit trend_path(result: [result1.id, result3.id])
      show_plot_btn = find('.trend-request-plot-button')
      show_plot_btn.click

      within('#trend-requests-plot') do
        expect(page).to have_selector('div.svg-container')
      end
    end

    scenario 'Click on All request' do
      DatabaseCleaner.clean
      label = 'login :GET'
      result1 = create(:result, release_date: '01.01.1978 00:01')
      result2 = create(:result, release_date: '01.01.1978 00:02')
      result3 = create(:result, release_date: '01.01.1978 00:03')
      [result1, result2, result3].each do |result|
        create(:requests_result, result_id: result.id, label: label)
      end
      [result1, result2, result3].each do |result|
        create(:calculated_requests_result, result_id: result.id, label: label)
      end
      visit trend_path(result: [result1.id, result3.id])
      click_button 'All requests trend plot'
      expect(page).to have_selector('div.svg-container')
    end

  end

  context 'Performance' do

    before(:all) do
      @result1 = create(:result, release_date: '01.01.1978 00:00')
      @result2 = create(:result, release_date: '01.01.1978 00:01')
      @result3 = create(:result, release_date: '01.01.1978 00:02')

      create(:calculated_requests_result, result_id: @result1.id)
      create(:calculated_requests_result, result_id: @result2.id)
      create(:calculated_requests_result, result_id: @result3.id)

      create(:calculated_performance_result, result_id: @result1.id, label: 'web00 CPU Processor Time')
      create(:calculated_performance_result, result_id: @result1.id, label: 'web00 Memory Memory\Available')
      create(:calculated_performance_result, result_id: @result1.id, label: 'web00 EXEC Network\Bytes Sent/sec')

      create(:calculated_performance_result, result_id: @result2.id, label: 'web00 CPU Processor Time')
      create(:calculated_performance_result, result_id: @result2.id, label: 'web00 Memory Memory\Available')
      create(:calculated_performance_result, result_id: @result2.id, label: 'web00 EXEC Network\Bytes Sent/sec')

      create(:calculated_performance_result, result_id: @result3.id, label: 'web00 CPU Processor Time')
      create(:calculated_performance_result, result_id: @result3.id, label: 'web00 Memory Memory\Available')
      create(:calculated_performance_result, result_id: @result3.id, label: 'web00 EXEC Network\Bytes Sent/sec')

    end

    scenario 'Performance section present' do
      visit trend_path(result: [@result1.id, @result3.id])
      expect(page).to have_selector('div#performance_trend')

    end

    scenario 'All performance group present in performance section' do
      visit trend_path(result: [@result1.id, @result3.id])
      performance_groups = []
      within('div#performance_trend') do
        performance_groups = all('input.show-plot').map{|button| button.value}
      end
      expect(performance_groups).to match_array(['Processor', 'Memory', 'Network traffic'])
    end

    scenario 'Click on button with performance group name' do
      visit trend_path(result: [@result1.id, @result3.id])
      show_processor_plot = find_button('Processor')
      plot_id = show_processor_plot.find(:xpath,".//..")[:action].match(/plot_id=(.*)/)[1]
      show_processor_plot.click
      expect(find("div##{plot_id}_div")['aria-expanded']).to eql('true')
    end
  end
end
