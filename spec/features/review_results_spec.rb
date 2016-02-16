require 'feature_helper'
require 'rails_helper'
require 'active_support/time_with_zone'

feature 'Review results' do
  scenario 'Uploaded results exist on the results page' do
    result = create(:result)
    expected_result =
      [result.version, result.rps.to_s, result.duration.to_s, result.profile, Time.zone.parse(result.test_run_date.to_s).strftime('%d.%m.%Y %H:%M'), Time.zone.parse(result.created_at.to_s).strftime('%d.%m.%Y %H:%M')]
    visit '/results/'
    results_rows = []
    page.all('table#results tr.result_row').each do |row|
      version = row.find('td.version').text
      rps = row.find('td.rps').text
      duration = row.find('td.duration').text
      profile = row.find('td.profile').text
      run_date = Time.zone.parse(row.find('td.test_run_date').text).strftime('%d.%m.%Y %H:%M')
      created_at = Time.zone.parse(row.find('td.created_at').text).strftime('%d.%m.%Y %H:%M')
      results_rows.push [version, rps, duration, profile, run_date, created_at]
    end
    expect(results_rows.include?(expected_result)).to be(true), 'Result from database is not displayed'
  end

  context 'Upload form' do
    let(:summary_file_path) { File.join(fixture_path, 'summary.csv').normalize_path }
    let(:perfmon_file_path) { File.join(fixture_path, 'perfmon.csv').normalize_path }

    scenario 'The table with results contains the uploaded results' do
      visit '/results/new'
      fill_in 'version', with: 'edu sharding'
      fill_in 'rps', with: '600'
      fill_in 'duration', with: '600'
      fill_in 'profile', with: 'all_sites'
      fill_in 'date_', with: '14.02.2016 17:45'
      attach_file 'requests_data', summary_file_path
      attach_file 'perfmon_data', perfmon_file_path
      click_button 'Upload'
      actual_create_at = Time.now.utc.strftime('%d.%m.%Y %H:%M')
      expected_row = ['edu sharding', '600', '600', 'all_sites', '14.02.2016 17:45', actual_create_at]
      results_rows = []
      page.all('table#results tr.result_row').each do |row|
        version = row.find('td.version').text
        rps = row.find('td.rps').text
        duration = row.find('td.duration').text
        profile = row.find('td.profile').text
        run_date = Time.parse(row.find('td.test_run_date').text)
        run_date = run_date.strftime('%d.%m.%Y %H:%M')
        created_at = Time.parse(row.find('td.created_at').text).strftime('%d.%m.%Y %H:%M')
        results_rows.push [version, rps, duration, profile, run_date, created_at]
      end
      expect(results_rows.include?(expected_row)).to be(true), 'Just uploaded result is not displayed'
    end
  end
end
