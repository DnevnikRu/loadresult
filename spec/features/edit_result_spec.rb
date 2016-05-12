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
          time_cutting_percent: '10',
          value_smoothing_interval: '11',
          release_date: '2011-11-11 11:00:01',
          comment: 'It is just a comment'
      )
      create(:requests_result, result_id: result.id, timestamp: 1455023039548, value: 2)
      create(:requests_result, result_id: result.id, timestamp: 1455023040000, value: 123)
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
      fill_in 'time_cutting_percent', with: '20'
      fill_in 'value_smoothing_interval', with: '9'
      fill_in 'release_date', with: '2016-12-12 10:00:00'
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
        expect(find('.time_cutting_percent')).to have_content('20')
        expect(find('.value_smoothing_interval')).to have_content('9')
        expect(find('.release_date')).to have_content('2016-12-12 10:00:00 UTC')
        expect(find('.comment')).to have_content('New comment')
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
        expect(find('.time_cutting_percent')).to have_content(@result.time_cutting_percent)
        expect(find('.value_smoothing_interval')).to have_content(@result.value_smoothing_interval)
        expect(find('.release_date')).to have_content(@result.release_date)
        expect(find('.comment')).to have_content(@result.comment)
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

  context 'When release date is changed to incorrect' do
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
      fill_in 'release_date', with: 'blablabla'
      click_button 'Update'
    end

    scenario 'Message about wrong format is displayed' do
      expect(page).to have_content('Release date must be a valid datetime')
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
          time_cutting_percent: '10',
          value_smoothing_interval: '11',
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
      fill_in 'time_cutting_percent', with: ''
      fill_in 'value_smoothing_interval', with: ''
      fill_in 'release_date', with: ''
      fill_in 'comment', with: ''
      click_button 'Update'
    end

    scenario 'Message with error appears' do
      expect(page).to have_content(%(Project can't be blank
            Version can't be blank
            Duration can't be blank
            Rps can't be blank
            Profile can't be blank))
    end

    context 'On the results page' do
      scenario 'All fields are remain unchanged' do
        visit '/results/'
        within(:xpath, @row_with_result_xpath) do
          expect(find('.project')).to have_content('Dnevnik')
          expect(find('.version')).to have_content(@result.version)
          expect(find('.rps')).to have_content(@result.rps)
          expect(find('.duration')).to have_content(@result.duration)
          expect(find('.profile')).to have_content(@result.profile)
          expect(find('.time_cutting_percent')).to have_content(@result.time_cutting_percent)
          expect(find('.value_smoothing_interval')).to have_content(@result.value_smoothing_interval)
          expect(find('.release_date')).to have_content(@result.release_date)
          expect(find('.comment')).to have_content(@result.comment)
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
          time_cutting_percent: '10',
          value_smoothing_interval: '11',
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
