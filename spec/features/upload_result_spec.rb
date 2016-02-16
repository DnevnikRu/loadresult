require 'feature_helper'

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

  context 'Upload form' do
    let(:summary_file_path) { File.expand_path('../../resources/summary.csv', __FILE__).normalize_path }
    let(:perfmon_file_path) { File.expand_path('../../resources/perfmon.csv', __FILE__).normalize_path }

    before do
      visit '/results/new'
    end

    scenario 'Upload a result with all fields filled' do
      fill_in 'version', with: 'edu sharding'
      fill_in 'rps', with: '600'
      fill_in 'duration', with: '600'
      fill_in 'profile', with: 'all_sites'
      fill_in 'date_', with: '14.02.2016 17:45'
      attach_file 'requests_data', summary_file_path
      attach_file 'perfmon_data', perfmon_file_path
      click_button 'Upload'

      expect(page).to have_content('Result was successfully created.')
    end

    scenario 'Upload a result without a perfmon file' do
      fill_in 'version', with: 'edu sharding'
      fill_in 'rps', with: '600'
      fill_in 'duration', with: '600'
      fill_in 'profile', with: 'all_sites'
      fill_in 'date_', with: '14.02.2016 17:45'
      attach_file 'requests_data', summary_file_path
      click_button 'Upload'

      expect(page).to have_content('Result was successfully created.')
    end

    scenario 'Can not upload a result without additional information' do
      attach_file 'requests_data', summary_file_path
      attach_file 'perfmon_data', perfmon_file_path
      click_button 'Upload'

      expect(page).to have_content(
        %(Version can't be blank
        Duration can't be blank
        Rps can't be blank
        Profile can't be blank
        Test run date must be in a datetime format)
      )
    end

    scenario 'Can not upload a result without a summary file' do
      fill_in 'version', with: 'edu sharding'
      fill_in 'rps', with: '600'
      fill_in 'duration', with: '600'
      fill_in 'profile', with: 'all_sites'
      fill_in 'date_', with: '14.02.2016 17:45'
      attach_file 'perfmon_data', perfmon_file_path
      click_button 'Upload'

      expect(page).to have_content('Request data is required')
    end
  end
end
