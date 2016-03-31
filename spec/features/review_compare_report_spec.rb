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
end
