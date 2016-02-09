When(/^I visit homepage$/) do
  visit root_path
end

Then(/^I see page with title "([^"]*)"$/) do |title|
  expect(page).to have_content(title)
end

And(/^I click on Upload results$/) do

end