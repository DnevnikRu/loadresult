require 'feature_helper'

feature 'Review compare report' do
  before(:all) do
    label = 'login :GET'

    @result1 = create(:result)
    create(:requests_result, result_id: @result1.id, label: label)
    create(:calculated_requests_result, result_id: @result1.id, label: label)

    @result2 = create(:result)
    create(:requests_result, result_id: @result2.id, label: label)
    create(:calculated_requests_result, result_id: @result2.id, label: label)
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

  scenario 'All requests historgram button opens a plot' do
    visit compare_path(result: [@result1.id, @result2.id])
    click_button 'Percentile of requests'

    within('#percentile_requests_plot') do
      expect(page).to have_selector('div.svg-container')
    end
  end

  scenario 'All requests historgram button opens a plot' do
    visit compare_path(result: [@result1.id, @result2.id])
    click_on 'Requests Data'
    show_plot_btn = find_button 'login :GET'
    show_plot_btn.click

    within(show_plot_btn['data-target']) do
      expect(page).to have_selector('div.svg-container')
    end
  end
end
