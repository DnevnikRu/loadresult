require 'feature_helper'

feature 'Upload load result' do
  scenario 'Open the upload page using the navigation bar' do
    visit '/'
    within('.navbar') do
      click_link 'Upload results'
    end

    expect(page).to have_css('h1', text: 'New Result')
  end

  context 'Upload form' do
    let(:summary_file_path) { File.join(fixture_path, 'summary.csv').normalize_path }
    let(:perfmon_file_path) { File.join(fixture_path, 'perfmon.csv').normalize_path }

    before do
      visit '/results/new'
    end

    scenario 'Upload a result with all fields filled corectly' do
      select 'Dnevnik', from: 'project'
      fill_in 'version', with: 'edu sharding'
      fill_in 'rps', with: '600'
      fill_in 'duration', with: '600'
      fill_in 'profile', with: 'all_sites'
      fill_in 'test_run_date', with: '14.02.2016 17:45'
      fill_in 'release_date', with: '14.02.2016 17:45'
      attach_file 'requests_data', summary_file_path
      attach_file 'performance_data', perfmon_file_path
      click_button 'Upload'

      expect(page).to have_content('Result was successfully created.')
    end

    scenario 'Upload a result without a perfmon file' do
      select 'Dnevnik', from: 'project'
      fill_in 'version', with: 'edu sharding'
      fill_in 'rps', with: '600'
      fill_in 'duration', with: '600'
      fill_in 'profile', with: 'all_sites'
      fill_in 'test_run_date', with: '14.02.2016 17:45'
      attach_file 'requests_data', summary_file_path
      click_button 'Upload'

      expect(page).to have_content('Result was successfully created.')
    end

    scenario 'Can not upload a result without filling information' do
      click_button 'Upload'

      expect(page).to have_content(%(Project can't be blank
        Version can't be blank
        Duration can't be blank
        Rps can't be blank
        Profile can't be blank
        Test run date must be in a datetime format
        Request data is required))
    end

    scenario 'Can not upload a result without additional information' do
      attach_file 'requests_data', summary_file_path
      click_button 'Upload'

      expect(page).to have_content(%(Project can't be blank
        Version can't be blank
        Duration can't be blank
        Rps can't be blank
        Profile can't be blank
        Test run date must be in a datetime format))
    end

    scenario 'Can not upload a result without a summary file' do
      select 'Dnevnik', from: 'project'
      fill_in 'version', with: 'edu sharding'
      fill_in 'rps', with: '600'
      fill_in 'duration', with: '600'
      fill_in 'profile', with: 'all_sites'
      fill_in 'test_run_date', with: '14.02.2016 17:45'
      attach_file 'performance_data', perfmon_file_path
      click_button 'Upload'

      expect(page).to have_content('Request data is required')
    end

    scenario 'Can not upload a result with invalid release date' do
      select 'Dnevnik', from: 'project'
      fill_in 'version', with: 'edu sharding'
      fill_in 'rps', with: '600'
      fill_in 'duration', with: '600'
      fill_in 'profile', with: 'all_sites'
      fill_in 'test_run_date', with: '14.02.2016 17:45'
      fill_in 'release_date', with: 'blablabla'
      attach_file 'performance_data', perfmon_file_path
      click_button 'Upload'

      expect(page).to have_content('Release date must be a valid datetime')
    end


    scenario 'Data in the form is saved if there is an error' do
      select 'Dnevnik', from: 'project'
      fill_in 'version', with: 'first version'
      fill_in 'rps', with: '500'
      fill_in 'duration', with: '450'
      fill_in 'profile', with: 'main'
      fill_in 'test_run_date', with: '21.02.2016 01:43'
      click_button 'Upload'

      expect(page).to have_field('version', with: 'first version')
      expect(page).to have_field('rps', with: '500')
      expect(page).to have_field('duration', with: '450')
      expect(page).to have_field('profile', with: 'main')
      expect(page).to have_field('test_run_date', with: '21.02.2016 01:43')
    end

    scenario 'Redirects to the results page' do
      select 'Dnevnik', from: 'project'
      fill_in 'version', with: 'first version'
      fill_in 'rps', with: '500'
      fill_in 'duration', with: '450'
      fill_in 'profile', with: 'main'
      fill_in 'test_run_date', with: '21.02.2016 01:43'
      attach_file 'requests_data', summary_file_path
      click_button 'Upload'

      expect(page).to have_current_path(results_path)
    end
  end
end
