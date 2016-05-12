require 'feature_helper'

describe 'Show Result page' do
  before do
    @result = create(:result)
  end

  scenario 'Show Result page can be open from the results page' do
    visit '/results/'
    within(:xpath, "//td[contains(@class, 'id') and text()='#{@result.id}']/..") do
      find('.showResult').click
    end

    expect(page).to have_current_path(result_path(@result))
  end

  scenario 'Show Result page shows id of a result' do
    visit result_path(@result)

    expect(page).to have_content(@result.id)
  end

  scenario 'Show Result without summary file' do
    visit result_path(@result)

    expect(page).to have_content('Requests data file does not exist')
  end
end
