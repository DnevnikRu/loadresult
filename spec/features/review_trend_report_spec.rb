require 'feature_helper'

feature 'Review trend report' do
  before(:all) do
    @result1 = create(:result)
    @result2 = create(:result)
    @result3 = create(:result)

    request_label = 'login :GET'
    create(:requests_result, result_id: @result1.id, label: request_label)
    create(:calculated_requests_result, result_id: @result1.id, label: request_label)
    create(:requests_result, result_id: @result2.id, label: request_label)
    create(:calculated_requests_result, result_id: @result2.id, label: request_label)
    create(:requests_result, result_id: @result3.id, label: request_label)
    create(:calculated_requests_result, result_id: @result3.id, label: request_label)

    performance_label = 'web00 CPU Processor Time'
    create(:performance_result, result_id: @result1.id, label: performance_label)
    create(:calculated_performance_result, result_id: @result1.id, label: performance_label)
    create(:performance_result, result_id: @result2.id, label: performance_label)
    create(:calculated_performance_result, result_id: @result2.id, label: performance_label)
    create(:performance_result, result_id: @result3.id, label: performance_label)
    create(:calculated_performance_result, result_id: @result3.id, label: performance_label)
  end

  scenario 'Redirects to the resutls page if there is one id' do
    visit trend_path(result: [@result1.id])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content 'You should select 2 or more results to create a trend'
  end

  scenario 'Redirects to the resutls page if there are no ids' do
    visit trend_path(result: [])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content 'You should select 2 or more results to create a trend'
  end

  scenario 'Redirects to the resutls page if ids are absent' do
    visit trend_path(result: [999997, 999999])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content "Can't find selected results"
  end

  scenario 'Redirects to the resutls page if one id is absent' do
    visit trend_path(result: [@result1.id, 999999])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content "Can't find selected results"
  end

  scenario 'Redirects to the resutls page if there are only two results between selected results' do
    visit trend_path(result: [@result1.id, @result3.id])

    expect(page).to have_current_path(results_path)
    expect(page).to have_content "Can't create a trend for 2 results"
  end
end
