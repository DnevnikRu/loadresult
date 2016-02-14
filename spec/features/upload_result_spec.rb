require 'rails_helper'

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

  scenario 'Upload a result with all fields filled'

  scenario 'Upload a result without a perfmon file'

  scenario 'Can not upload a result without additional information'

  scenario 'Can not upload a result without a summary file'
end
