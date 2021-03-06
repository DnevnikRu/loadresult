require 'feature_helper'

describe 'Editing a result' do
  context 'When fields are filled properly' do
    before do
      result = create(
          :result,
          project_id: '1',
          version: '1.0.0',
          rps: '10',
          duration: '100',
          profile: 'main',
          test_run_date: '2013-09-09 13:00:03',
          time_cutting_percent: '10',
          smoothing_percent: '11',
          release_date: '2011-11-11 11:00:01',
          comment: 'It is just a comment'
      )
      create(:requests_result, result_id: result.id, timestamp: 1455023039548, value: 2)
      create(:requests_result, result_id: result.id, timestamp: 1455023040000, value: 123)
      create(:requests_result, result_id: result.id, timestamp: 1455023041000, value: 123)
      create(:requests_result, result_id: result.id, timestamp: 1455023042000, value: 123)
      create(:requests_result, result_id: result.id, timestamp: 1455023042100, value: 123)
      create(:requests_result, result_id: result.id, timestamp: 1455023042200, value: 123)
      create(:requests_result, result_id: result.id, timestamp: 1455023043000, value: 123)
      create(:requests_result, result_id: result.id, timestamp: 1455023044000, value: 123)
      create(:requests_result, result_id: result.id, timestamp: 1455023045000, value: 121)
      visit '/results/'
      @row_with_result_xpath = "//td[contains(@class, 'id') and text()='#{result.id}']/.."
      within(:xpath, @row_with_result_xpath) do
        find('.editResult').click
      end
      select 'Contingent', from: 'project'
      fill_in 'version', with: 'New version'
      fill_in 'rps', with: '666'
      fill_in 'duration', with: '999'
      fill_in 'profile', with: 'New profile'
      fill_in 'data_version', with: 'Current data version'
      fill_in 'test_run_date', with: '10.10.2014 14:14'
      fill_in 'time_cutting_percent', with: '20'
      fill_in 'smoothing_percent', with: '3'
      fill_in 'release_date', with: '12.12.2016 10:00'
      fill_in 'comment', with: 'New comment'
      click_button 'Update'
    end

    scenario 'All edited fields on the results page are changed' do
      within(:xpath, @row_with_result_xpath) do
        expect(find('.project')).to have_content('Contingent')
        expect(find('.version')).to have_content('New version')
        expect(find('.rps')).to have_content('666')
        expect(find('.duration')).to have_content('999')
        expect(find('.profile')).to have_content('New profile')
        expect(find('.data_version')).to have_content('Current data version')
        expect(find('.test_run_date')).to have_content('2014-10-10 14:14:00 UTC')
        expect(find('.time_cutting_percent')).to have_content('20')
        expect(find('.smoothing_percent')).to have_content('3')
        expect(find('.release_date')).to have_content('2016-12-12')
        within('.comment') { expect(find('.glyphicon-envelope')).to_not be_nil }
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
      @result = create(
          :result,
          project_id: '1',
          version: '1.0.0',
          rps: '10',
          duration: '100',
          profile: 'main',
          test_run_date: '2013-09-09 13:00:03',
          time_cutting_percent: '10',
          smoothing_percent: '11',
          release_date: '2011-11-11 11:00:01',
          comment: 'It is just a comment'
      )
      create(:requests_result, result_id: @result.id, timestamp: 1455023039548, value: 2)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123)
      create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 121)
      visit '/results/'
      @row_with_result_xpath = "//td[contains(@class, 'id') and text()='#{@result.id}']/.."
      within(:xpath, @row_with_result_xpath) do
        find('.editResult').click
      end
      click_button 'Update'
    end

    scenario 'All fields on the results page are remain unchanged' do
      within(:xpath, @row_with_result_xpath) do
        expect(find('.project')).to have_content('Dnevnik')
        expect(find('.version')).to have_content(@result.version)
        expect(find('.rps')).to have_content(@result.rps)
        expect(find('.duration')).to have_content(@result.duration)
        expect(find('.profile')).to have_content(@result.profile)
        expect(find('.data_version')).to have_content(@result.data_version)
        expect(find('.test_run_date')).to have_content(@result.data_version)
        expect(find('.time_cutting_percent')).to have_content(@result.time_cutting_percent)
        expect(find('.smoothing_percent')).to have_content(@result.smoothing_percent)
        expect(find('.release_date')).to have_content(@result.release_date.to_date)
        within('.comment') { expect(find('.glyphicon-envelope')).to_not be_nil }
      end
    end

    scenario 'Successful message appears' do
      expect(page).to have_content('Result was successfully updated.')
    end

    scenario 'Redirects to the results page' do
      expect(page).to have_current_path(results_path)
    end
  end

  context 'When time cut is changed to empty' do
    before do
      @result = create(:result)
      create(:requests_result, result_id: @result.id, timestamp: 1455023039548, value: 2)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123)
      create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 121)
      visit '/results/'
      @row_with_result_xpath = "//td[contains(@class, 'id') and text()='#{@result.id}']/.."
      within(:xpath, @row_with_result_xpath) do
        find('.editResult').click
      end
      fill_in 'time_cutting_percent', with: ''
      click_button 'Update'
    end

    scenario 'Edit time cutting percent with empty data' do
      within(:xpath, @row_with_result_xpath) do
        expect(find('.time_cutting_percent')).to have_content('0')
      end
    end

  end

  context 'When fields are changed to empty' do
    before do
      @result = create(
          :result,
          project_id: '1',
          version: '1.0.0',
          rps: '10',
          duration: '100',
          profile: 'main',
          data_version: 'Current data version',
          test_run_date: '2013-10-10 13:00:03',
          time_cutting_percent: '10',
          smoothing_percent: '11',
          release_date: '2011-11-11 11:00:01',
          comment: 'It is just a comment'
      )
      create(:requests_result, result_id: @result.id, timestamp: 1455023039548, value: 2)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123)
      create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 121)
      visit '/results/'
      @row_with_result_xpath = "//td[contains(@class, 'id') and text()='#{@result.id}']/.."
      within(:xpath, @row_with_result_xpath) do
        find('.editResult').click
      end
      select '', from: 'project'
      fill_in 'version', with: ''
      fill_in 'rps', with: ''
      fill_in 'duration', with: ''
      fill_in 'profile', with: ''
      fill_in 'data_version', with: ''
      fill_in 'test_run_date', with: ''
      fill_in 'time_cutting_percent', with: ''
      fill_in 'smoothing_percent', with: ''
      fill_in 'release_date', with: ''
      fill_in 'comment', with: ''
      click_button 'Update'
    end

    scenario 'Message with error appears' do
      expect(page).to have_content(%(Project can't be blank
            Version can't be blank
            Duration can't be blank
            Rps can't be blank
            Profile can't be blank
            Test run date must be in a datetime))
    end

    context 'On the results page' do
      scenario 'All fields are remain unchanged' do
        visit '/results/'
        within(:xpath, @row_with_result_xpath) do
          expect(find('.project')).to have_content('Dnevnik')
          expect(find('.version')).to have_content(@result.version)
          expect(find('.rps')).to have_content(@result.rps)
          expect(find('.duration')).to have_content(@result.duration)
          expect(find('.test_run_date')).to have_content(@result.time_cutting_percent)
          expect(find('.profile')).to have_content(@result.profile)
          expect(find('.data_version')).to have_content(@result.data_version)
          expect(find('.time_cutting_percent')).to have_content(@result.time_cutting_percent)
          expect(find('.smoothing_percent')).to have_content(@result.smoothing_percent)
          expect(find('.release_date')).to have_content(@result.release_date.to_date)
          within('.comment') { expect(find('.glyphicon-envelope')).to_not be_nil }
        end
      end
    end
  end

  context 'When rps changed to string' do
    before do
      result = create(
          :result,
          project_id: '1',
          version: '1.0.0',
          rps: '10',
          duration: '100',
          profile: 'main',
          data_version: 'Current data version',
          test_run_date: '2013-10-10 13:00:03',
          time_cutting_percent: '10',
          smoothing_percent: '11',
          release_date: '2011-11-11 11:00:01',
          comment: 'It is just a comment'
      )
      visit '/results/'
      @row_with_result_xpath = "//td[contains(@class, 'id') and text()='#{result.id}']/.."
      within(:xpath, @row_with_result_xpath) do
        find('.editResult').click
      end
      fill_in 'rps', with: '10-150'
      click_button 'Update'
    end

    scenario 'Result update successfully' do
      expect(page).to have_content('Result was successfully updated.')
    end
  end
end
