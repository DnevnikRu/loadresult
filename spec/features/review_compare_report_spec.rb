require 'feature_helper'

feature 'Review compare report' do
  before(:all) do
    @result1 = create(:result)
    @result2 = create(:result)

    request_label = 'login :GET'
    create(:requests_result, result_id: @result1.id, label: request_label)
    create(:calculated_requests_result, result_id: @result1.id, label: request_label)
    create(:requests_result, result_id: @result2.id, label: request_label)
    create(:calculated_requests_result, result_id: @result2.id, label: request_label)

    performance_label = 'web00 CPU Processor Time'
    create(:performance_result, result_id: @result1.id, label: performance_label)
    create(:calculated_performance_result, result_id: @result1.id, label: performance_label)
    create(:performance_result, result_id: @result2.id, label: performance_label)
    create(:calculated_performance_result, result_id: @result2.id, label: performance_label)
  end

  scenario 'Compare report contains description block' do
    visit compare_path(result: [@result1.id, @result2.id])

    expect(page).to have_selector('div#collapseDescription')
  end

  scenario 'Redirects to the resutls page if ids absent' do
    visit compare_path(result: [999998, 999999])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content "Can't find selected results"
  end

  scenario 'Redirects to the resutls page if there is one id' do
    visit compare_path(result: [@result1.id])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content 'You should select 2 or more results to compare them'
  end

  scenario 'Redirects to the resutls page if there are no ids' do
    visit compare_path(result: [])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content 'You should select 2 or more results to compare them'
  end

  scenario 'All requests historgram button opens a plot' do
    visit compare_path(result: [@result1.id, @result2.id])
    click_button 'All requests historgram'

    within('#all_requests_plot') do
      expect(page).to have_selector('div.svg-container')
    end
  end

  scenario 'Percentile of requests button opens a plot' do
    visit compare_path(result: [@result1.id, @result2.id])
    click_button 'Percentile of requests'

    within('#percentile_requests_plot') do
      expect(page).to have_selector('div.svg-container')
    end
  end

  scenario 'Click on a Show historgram of response time plot button shows a plot' do
    visit compare_path(result: [@result1.id, @result2.id])
    click_on 'Requests Data'
    show_plot_btn = find('.requests-histogram-plot-button')
    show_plot_btn.click

    within(show_plot_btn['data-target']) do
      expect(page).to have_selector('div.svg-container')
    end
  end

  scenario 'Click on a Show requests values to seconds button shows a plot' do
    visit compare_path(result: [@result1.id, @result2.id])
    click_on 'Requests Data'
    show_plot_btn = find('.requests-time-plot-button')
    show_plot_btn.click

    within(show_plot_btn['data-target']) do
      expect(page).to have_selector('div.svg-container')
    end
  end

  scenario 'Show a plot button opens a performance plot' do
    visit compare_path(result: [@result1.id, @result2.id])
    click_on 'Performance results'
    show_plot_btn = find_button 'Show a plot'
    show_plot_btn.click

    within(show_plot_btn['data-target']) do
      expect(page).to have_selector('div.svg-container')
    end
  end

  scenario 'Change result order' do
    visit compare_path(result: [@result1.id, @result2.id])
    click_on 'changed_results'
    current_uri = URI(page.current_url)
    expect("#{current_uri.path}?#{current_uri.query}").to eql(compare_path(result: [@result2.id, @result1.id]))
  end

  context 'Showing difference in attrubutes of results' do
    context 'When there are no differences' do
      before do
        result1 = create(:result)
        result2 = create(:result)
        visit compare_path(result: [result1.id, result2.id])
      end

      scenario 'Difference warning does not appear' do
        expect(page).to_not have_selector('#different-warning')
      end

      scenario 'In description block rows are not highlighted' do
        expect(page.all('.row-warning')).to be_empty
      end
    end

    context 'When there are differences' do
      before do
        DatabaseCleaner.clean
        result1 = create(
          :result,
          id: 500,
          version: 'first',
          duration: 100,
          rps: 100,
          profile: 'all_site1',
          test_run_date: '01.01.1978 00:00',
          time_cutting_percent: 10
        )
        result2 = create(
          :result,
          id: 501,
          version: 'second',
          duration: 200,
          rps: 200,
          profile: 'all_site2',
          test_run_date: '01.01.1979 00:00',
          time_cutting_percent: 20
        )
        visit compare_path(result: [result1.id, result2.id])
      end

      scenario 'Difference warning appears' do
        difference_warning_text = find('#different-warning').text
        expected_warning =
          'Warning! You are comparing results that has differences: ' \
          "Duration: id:500 has '100' but id:501 has '200' " \
          "Rps: id:500 has '100' but id:501 has '200' " \
          "Profile: id:500 has 'all_site1' but id:501 has 'all_site2' " \
          "Time cutting percent: id:500 has '10' but id:501 has '20'"
        expect(difference_warning_text).to eq(expected_warning)
      end

      scenario 'In description block rows with differences highlighted' do
        rows_with_warning = [
          'Rps 100 200',
          'Duration 100 200',
          'Profile all_site1 all_site2',
          'Time cutting percent 10 20'
        ]
        expect(page.all('.row-warning').map(&:text)).to match_array(rows_with_warning)
      end
    end
  end
end
