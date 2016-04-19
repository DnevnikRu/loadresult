require 'feature_helper'
require 'active_support/time_with_zone'

feature 'Review results' do
  before { DatabaseCleaner.clean }

  scenario 'Uploaded results exist on the results page' do
    result = create(:result)
    expected_result =
        [result.version, result.rps.to_s, result.duration.to_s, result.profile, Time.zone.parse(result.test_run_date.to_s).strftime('%d.%m.%Y %H:%M')]
    visit '/results/'
    results_rows = []
    page.all('table#results-table tr.result_row').each do |row|
      version = row.find('td.version').text
      rps = row.find('td.rps').text
      duration = row.find('td.duration').text
      profile = row.find('td.profile').text
      run_date = Time.zone.parse(row.find('td.test_run_date').text).strftime('%d.%m.%Y %H:%M')
      results_rows.push [version, rps, duration, profile, run_date]
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
      fill_in 'test_run_date', with: '14.02.2016 17:45'
      attach_file 'requests_data', summary_file_path
      attach_file 'performance_data', perfmon_file_path
      click_button 'Upload'
      expected_row = ['edu sharding', '600', '600', 'all_sites', '14.02.2016 17:45']
      results_rows = []
      page.all('table#results-table tr.result_row').each do |row|
        version = row.find('td.version').text
        rps = row.find('td.rps').text
        duration = row.find('td.duration').text
        profile = row.find('td.profile').text
        run_date = Time.parse(row.find('td.test_run_date').text)
        run_date = run_date.strftime('%d.%m.%Y %H:%M')
        results_rows.push [version, rps, duration, profile, run_date]
      end
      expect(results_rows.include?(expected_row)).to be(true), 'Just uploaded result is not displayed'
    end
  end

  context 'Paginator' do
    scenario 'Paginator is visible when there are more than 20 results' do
      21.times { create(:result) }

      visit '/results/'

      expect(find('#paginator').text).to eq('1 2 Next › Last »')
    end

    scenario 'There is only one result on the second page when there are 21 results' do
      21.times { create(:result) }

      visit '/results/'
      click_on 'Next ›'

      expect(page).to have_selector('.result_row', count: 1)
    end

    scenario 'Paginator is not visible when there are 20 or less results' do
      20.times { create(:result) }

      visit '/results/'

      expect(find('#paginator').text).to eq('')
    end

    scenario 'Selecting two results on different pages and clicking on Compare opens Compare page' do
      21.times { create(:result) }

      visit '/results/'
      page.all('.result_row').first.click
      wait_for_ajax
      click_on 'Next ›'
      find('.result_row').click
      wait_for_ajax
      click_on 'Compare'

      expect(find('h1')).to have_content('Compare report')
    end
  end

  scenario 'Selecting two results and clicking on Compare clear checked results' do
    2.times { create(:result) }

    visit '/results/'
    page.all('.result_row').each do |row|
      row.click
      wait_for_ajax
    end
    click_on 'Compare'
    wait_for_ajax
    expect(find('h1')).to have_content('Compare report')
    visit '/results/'

    page.all('.result-checkbox').each do |checkbox|
      expect(checkbox).to_not be_checked
    end
  end

  scenario 'Results are not checked by default' do
    10.times { create(:result) }

    visit '/results/'

    page.all('.result-checkbox').each do |checkbox|
      expect(checkbox).to_not be_checked
    end
  end

  scenario 'Selecting two results and clicking on Compare opens Compare page' do
    2.times { create(:result) }

    visit '/results/'
    page.all('.result_row').each do |row|
      row.click
      wait_for_ajax
    end
    click_on 'Compare'
    wait_for_ajax

    expect(find('h1')).to have_content('Compare report')
  end

  scenario 'Selecting results and clicking on Trend opens Trend page and clear checked results' do
    create(:result, test_run_date: '01.01.1978 00:01')
    create(:result, test_run_date: '01.01.1978 00:02')
    create(:result, test_run_date: '01.01.1978 00:03')

    visit '/results/'
    page.all('.result_row').first.click
    wait_for_ajax
    page.all('.result_row').last.click
    wait_for_ajax
    click_on 'Trend'

    expect(find('h1')).to have_content('Trend')
    visit '/results/'

    page.all('.result-checkbox').each do |checkbox|
      expect(checkbox).to_not be_checked
    end
  end
end
