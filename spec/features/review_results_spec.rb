require 'feature_helper'
require 'active_support/time_with_zone'

feature 'Review results' do
  scenario 'Uploaded results exist on the results page' do
    result = create(:result)
    actual_create_at =Time.zone.parse(result.created_at.to_s)
    time_range = actual_create_at-60..actual_create_at+60
    expected_result =
        [result.version, result.rps.to_s, result.duration.to_s, result.profile, Time.zone.parse(result.test_run_date.to_s).strftime('%d.%m.%Y %H:%M'), time_range.cover?(actual_create_at)]
    visit '/results/'
    results_rows = []
    page.all('table#results-table tr.result_row').each do |row|
      version = row.find('td.version').text
      rps = row.find('td.rps').text
      duration = row.find('td.duration').text
      profile = row.find('td.profile').text
      run_date = Time.zone.parse(row.find('td.test_run_date').text).strftime('%d.%m.%Y %H:%M')
      created_at =Time.zone.parse(row.find('td.created_at').text)
      results_rows.push [version, rps, duration, profile, run_date, time_range.cover?(created_at)]
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
      attach_file 'perfmon_data', perfmon_file_path
      click_button 'Upload'
      actual_create_at = Time.now.utc
      time_range = actual_create_at-60..actual_create_at+60
      expected_row = ['edu sharding', '600', '600', 'all_sites', '14.02.2016 17:45', time_range.cover?(actual_create_at)]
      results_rows = []
      page.all('table#results-table tr.result_row').each do |row|
        version = row.find('td.version').text
        rps = row.find('td.rps').text
        duration = row.find('td.duration').text
        profile = row.find('td.profile').text
        run_date = Time.parse(row.find('td.test_run_date').text)
        run_date = run_date.strftime('%d.%m.%Y %H:%M')
        created_at =Time.parse(row.find('td.created_at').text)
        results_rows.push [version, rps, duration, profile, run_date, time_range.cover?(created_at)]
      end
      expect(results_rows.include?(expected_row)).to be(true), 'Just uploaded result is not displayed'
    end
  end

  scenario 'Destroy a result' do
    result = create(:result)
    visit '/results/'
    row_with_result_xpath = "//td[@class='id' and text()='#{result.id}']/.."
    accept_alert do
      within(:xpath, row_with_result_xpath) do
        find('.destroyResult').click
      end
    end

    expect(page).to_not have_xpath(row_with_result_xpath)
  end

  context 'When edit a result' do
    context 'When fields are filled properly' do
      before do
        result = create(:result)
        visit '/results/'
        @row_with_result_xpath = "//td[@class='id' and text()='#{result.id}']/.."
        within(:xpath, @row_with_result_xpath) do
          find('.editResult').click
        end
        fill_in 'version', with: 'New version'
        fill_in 'rps', with: '666'
        fill_in 'duration', with: '999'
        fill_in 'profile', with: 'New profile'
        click_button 'Update'
      end

      scenario 'All edited fields on the results page are changed' do
        within(:xpath, @row_with_result_xpath) do
          expect(find('.version')).to have_content('New version')
          expect(find('.rps')).to have_content('666')
          expect(find('.duration')).to have_content('999')
          expect(find('.profile')).to have_content('New profile')
        end
      end

      scenario 'Successful message appears' do
        expect(page).to have_content('Result was successfully updated.')
      end

      scenario 'Redirects to the results page' do
        expect(page).to have_current_path(results_path)
      end
    end

    context 'When fields are not edited' do
      before do
        @result = create(:result)
        visit '/results/'
        @row_with_result_xpath = "//td[@class='id' and text()='#{@result.id}']/.."
        within(:xpath, @row_with_result_xpath) do
          find('.editResult').click
        end
        click_button 'Update'
      end

      scenario 'All fields on the results page are remain unchanged' do
        within(:xpath, @row_with_result_xpath) do
          expect(find('.version')).to have_content(@result.version)
          expect(find('.rps')).to have_content(@result.rps)
          expect(find('.duration')).to have_content(@result.duration)
          expect(find('.profile')).to have_content(@result.profile)
        end
      end

      scenario 'Successful message appears' do
        expect(page).to have_content('Result was successfully updated.')
      end

      scenario 'Redirects to the results page' do
        expect(page).to have_current_path(results_path)
      end
    end

    context 'When fields are changed to empty' do
      before do
        @result = create(:result)
        visit '/results/'
        @row_with_result_xpath = "//td[@class='id' and text()='#{@result.id}']/.."
        within(:xpath, @row_with_result_xpath) do
          find('.editResult').click
        end
        fill_in 'version', with: ''
        fill_in 'rps', with: ''
        fill_in 'duration', with: ''
        fill_in 'profile', with: ''
        click_button 'Update'
      end

      scenario 'All edited fields have previous text' do
        expect(page).to have_field('version', with: @result.version)
        expect(page).to have_field('rps', with: @result.rps)
        expect(page).to have_field('duration', with: @result.duration)
        expect(page).to have_field('profile', with: @result.profile)
      end

      scenario 'Message with error appears' do
        expect(page).to have_content(%(Version can't be blank
            Duration can't be blank
            Rps can't be blank
            Profile can't be blank))
      end

      context 'On the results page' do
        scenario 'All fields are remain unchanged' do
          visit '/results/'
          within(:xpath, @row_with_result_xpath) do
            expect(find('.version')).to have_content(@result.version)
            expect(find('.rps')).to have_content(@result.rps)
            expect(find('.duration')).to have_content(@result.duration)
            expect(find('.profile')).to have_content(@result.profile)
          end
        end
      end
    end
  end
end
