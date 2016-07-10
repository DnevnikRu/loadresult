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
      select 'Dnevnik', from: 'project'
      fill_in 'version', with: 'edu sharding'
      fill_in 'rps', with: '600'
      fill_in 'duration', with: '600'
      fill_in 'profile', with: 'all_sites'
      fill_in 'data_version', with: 'version of data'
      fill_in 'test_run_date', with: '14.02.2016 17:45'
      attach_file 'requests_data', summary_file_path
      attach_file 'performance_data', perfmon_file_path
      click_button 'Upload'
      expected_row = ['Dnevnik', 'edu sharding', '600', '600', 'all_sites', 'version of data', '14.02.2016 17:45']
      results_rows = []
      page.all('table#results-table tr.result_row').each do |row|
        project = row.find('td.project').text
        version = row.find('td.version').text
        rps = row.find('td.rps').text
        duration = row.find('td.duration').text
        profile = row.find('td.profile').text
        data_version = row.find('td.data_version').text
        run_date = Time.parse(row.find('td.test_run_date').text)
        run_date = run_date.strftime('%d.%m.%Y %H:%M')
        results_rows.push [project, version, rps, duration, profile, data_version, run_date]
      end
      expect(results_rows).to include(expected_row)
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

      expect(page).to have_selector('.result-checkbox', count: 1)
    end

    scenario 'Paginator is not visible when there are 20 or less results' do
      20.times { create(:result) }

      visit '/results/'

      expect(find('#paginator').text).to eq('')
    end

    scenario 'Selecting two results on different pages and clicking on Compare opens Compare page' do
      21.times { create(:result) }

      visit '/results/'
      page.all('.result-checkbox').first.click
      click_on 'Next ›'
      find('.result-checkbox').click
      click_on 'Compare'

      expect(find('h1')).to have_content('Compare report')
    end
  end

  scenario 'Selecting two results and clicking on Compare opens Compare page' do
    2.times { create(:result) }

    visit '/results/'
    page.all('.result-checkbox').each do |row|
      row.click
    end
    click_on 'Compare'
    expect(find('h1')).to have_content('Compare report')
  end

  scenario 'Selecting two results and clicking on Trend opens Trend page' do
    create(:result, release_date: '01.01.1978 00:01')
    create(:result, release_date: '01.01.1978 00:02')
    create(:result, release_date: '01.01.1978 00:03')

    visit '/results/'
    page.all('.result-checkbox').first.click
    page.all('.result-checkbox').last.click
    click_on 'Trend'

    expect(find('h1')).to have_content('Trend')
  end

  scenario 'When there is no comment the comment icon is absent' do
    result = create(:result, comment: nil)

    visit '/results/'
    row_with_result_xpath = "//td[contains(@class, 'id') and text()='#{result.id}']/../td[contains(@class, 'comment')]"
    within(:xpath, row_with_result_xpath) do
      expect { find('.glyphicon-envelope') }.to raise_error(Capybara::ElementNotFound)
    end
  end

  context 'Selecting results' do
    scenario 'When 2 results are chosen others are disabled' do
      result1 = create(:result)
      result2 = create(:result)
      result3 = create(:result)

      visit '/results/'
      page.all('.result-checkbox').each(&:click)

      expect(page.all('.result-checkbox')[0][:disabled]).to_not eq('true')
      expect(page.all('.result-checkbox')[1][:disabled]).to_not eq('true')
      expect(page.all('.result-checkbox')[2][:disabled]).to eq('true')
      expect(page.find('#result-to-compare-list').text).to eq("Selected results: #{result1.id}, #{result2.id}")
      expect(find('#compare-button')[:href]).to include("/compare?result[]=#{result1.id}&result[]=#{result2.id}")

      page.all('.result-checkbox')[1].click

      page.all('.result-checkbox').each do |result|
        expect(result[:disabled]).to_not eq('true')
      end
      expect(page.find('#result-to-compare-list').text).to eq("Selected results: #{result1.id}")
      expect(find('#compare-button')[:href]).to include("/compare")
    end

    scenario 'Refreshing browser does not clear selected results' do
      result1 = create(:result)
      result2 = create(:result)

      visit '/results/'
      page.all('.result-checkbox').each(&:click)
      page.driver.browser.navigate.refresh

      expect(page.find('#result-to-compare-list').text).to eq("Selected results: #{result1.id}, #{result2.id}")
      expect(find('#compare-button')[:href]).to include("/compare?result[]=#{result1.id}&result[]=#{result2.id}")
      page.all('.result-checkbox').each do |result|
        expect(result).to be_checked
      end
    end

    scenario 'Clear results button clear selected results' do
      2.times { create(:result) }

      visit '/results/'
      page.all('.result-checkbox').each(&:click)
      find('#clear-results').click

      expect(page).to_not have_content("Selected results")
      expect(find('#compare-button')[:href]).to include("/compare")
      page.all('.result-checkbox').each do |result|
        expect(result).to_not be_checked
      end
    end

    scenario 'Clicking on a row toggles a checkbox in this row' do
      2.times { create(:result) }

      visit '/results/'
      page.all('.result_row')[0].click

      expect(page.all('.result-checkbox')[0]).to be_checked
      expect(page.all('.result-checkbox')[1]).to_not be_checked

      page.all('.result_row')[0].click

      expect(page.all('.result-checkbox')[0]).to_not be_checked
      expect(page.all('.result-checkbox')[1]).to_not be_checked
    end

    scenario 'Selected results are still selected after an error on Compare or Trend page' do
      result1 = create(:result)
      result2 = create(:result)

      visit '/results/'
      page.all('.result-checkbox')[0].click

      %w(Compare Trend).each do |btn_text|
        click_on btn_text

        expect(page.all('.result-checkbox')[0]).to be_checked
        expect(page.all('.result-checkbox')[1]).to_not be_checked
        expect(page.find('#result-to-compare-list').text).to eq("Selected results: #{result1.id}")
      end
    end

    scenario 'Clicking on Compare or Trend button clears selected results' do
      create(:result, release_date: '01.01.1978 00:01')
      create(:result, release_date: '01.01.1978 00:02')
      create(:result, release_date: '01.01.1978 00:03')

      %w(Compare Trend).each do |btn_text|
        visit '/results/'
        page.all('.result-checkbox').first.click
        page.all('.result-checkbox').last.click
        click_on btn_text
        visit '/results/'

        expect(page).to_not have_content("Selected results")
        expect(find('#compare-button')[:href]).to include("/compare")
        page.all('.result-checkbox').each do |result|
          expect(result).to_not be_checked
        end
      end
    end

    scenario 'Results are not checked by default' do
      10.times { create(:result) }

      visit '/results/'

      page.all('.result-checkbox').each do |checkbox|
        expect(checkbox).to_not be_checked
      end
    end

    scenario 'Filter does not clear results' do
      result1 = create(:result)
      result2 = create(:result)

      visit '/results/'
      page.all('.result-checkbox').each(&:click)
      select 'Dnevnik', from: 'filterrific_with_project_id'
      wait_for_ajax

      expect(page.find('#result-to-compare-list').text).to eq("Selected results: #{result1.id}, #{result2.id}")
      expect(find('#compare-button')[:href]).to include("/compare?result[]=#{result1.id}&result[]=#{result2.id}")
      page.all('.result-checkbox').each do |result|
        expect(result).to be_checked
      end
    end
  end
end

