require 'feature_helper'

feature 'Review result report' do
  before(:all) do
    DatabaseCleaner.clean
    @result = create(:result)

    request_label = 'login :GET'
    create(:requests_result, result_id: @result.id, label: request_label)
    create(:calculated_requests_result, result_id: @result.id, label: request_label)

    performance_label = 'web00 CPU Processor Time'
    create(:performance_result, result_id: @result.id, label: performance_label)
    create(:calculated_performance_result, result_id: @result.id, label: performance_label)


  end

  scenario 'Result report contains description block' do
    visit report_result_path(@result)
    expect(page).to have_selector('div#collapseDescription')
  end

  scenario 'All requests historgram button opens a plot' do
    visit report_result_path(@result)
    click_button 'All requests historgram'

    within('#all_requests_plot') do
      expect(page).to have_selector('div.svg-container')
    end
  end

  scenario 'Percentile of requests button opens a plot' do
    visit report_result_path(@result)
    click_button 'Percentile of requests'

    within('#percentile_requests_plot') do
      expect(page).to have_selector('div.svg-container')
    end
  end

  scenario 'Click on a Show historgram of response time plot button shows a plot' do
    visit report_result_path(@result)
    click_on 'Requests Data'
    show_plot_btn = find('.requests-histogram-plot-button')
    show_plot_btn.click

    within(show_plot_btn['data-target']) do
      expect(page).to have_selector('div.svg-container')
    end
  end

  scenario 'Click on a Show requests values to seconds button shows a plot' do
    visit report_result_path(@result)
    click_on 'Requests Data'
    show_plot_btn = find('.requests-time-plot-button')
    show_plot_btn.click

    within(show_plot_btn['data-target']) do
      expect(page).to have_selector('div.svg-container')
    end
  end

  scenario 'Show a plot button opens a performance plot' do
    visit report_result_path(@result)
    click_on 'Performance results'
    show_plot_btn = find_button 'Show a plot'
    show_plot_btn.click

    within(show_plot_btn['data-target']) do
      expect(page).to have_selector('div.svg-container')
    end
  end
end