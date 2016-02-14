require 'rails_helper'

feature 'Upload load result' do
  scenario 'Open the upload page from the homepage' do
    visit '/'
    within('.container') do
      click_link 'Upload results'
    end
    expect(page).to have_css('h1', text: 'Upload results')
  end

  scenario 'Open the upload page using the navigation bar' do
    visit '/'
    within('.navbar') do
      click_link 'Upload results'
    end
    expect(page).to have_css('h1', text: 'Upload results')
  end

  scenario 'Upload a result with all fields filled' do
    visit '/results/new'
    fill_in 'version', with: 'edu sharding'
    fill_in 'rps', with: '600'
    fill_in 'duration', with: '600'
    fill_in 'profile', with: 'all_sites'
    fill_in 'date_', with: '14.02.2016 17:45'
    attach_file 'requests_data', File.expand_path('../../resources/summary.csv', __FILE__)
    attach_file 'perfmon_data', File.expand_path('../../resources/perfmon.csv', __FILE__)
    click_button 'Upload'
    expect(page).to have_content('Result was successfully created.')
  end

  scenario 'Upload a result without a perfmon file'

  scenario 'Can not upload a result without additional information'

  scenario 'Can not upload a result without a summary file'
end
