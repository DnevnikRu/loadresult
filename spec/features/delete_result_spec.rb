require 'feature_helper'

describe 'Destroying a result' do
  scenario 'Removes result row that was destroyed' do
    result = create(:result)
    visit '/results/'
    row_with_result_xpath = "//td[contains(@class, 'id') and text()='#{result.id}']/.."
    accept_alert do
      within(:xpath, row_with_result_xpath) do
        find('.destroyResult').click
      end
    end

    expect(page).to_not have_xpath(row_with_result_xpath)
  end
end