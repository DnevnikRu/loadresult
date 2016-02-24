require 'feature_helper'

feature 'Review compare report' do

  before(:all) do
    @result1 = create(:result)
    @result2 = create(:result, version: 'master-2', test_run_date: '01.01.2016 00:00')
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

end
