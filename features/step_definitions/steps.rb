When(/^I visit homepage$/) do
  @browser.goto 'http://localhost:3000/'
end

When(/^I visit upload results page$/) do
  @browser.goto 'http://localhost:3000/results/new'
end

And(/^I click on Upload results$/) do
  pending
end

Then(/^I see page with title "([^"]*)"$/) do |title_expected|
  expect(on_page(ResultsNewPage).title_element.when_visible.text).to eq(title_expected)
end

And(/^Click menu Upload results in navigation bar$/) do
  on_page(ResultsIndexPage).upload_navbar
end

And(/^I fill all field about results$/) do
  pending
end

And(/^I choose summary file$/) do
  pending
end

And(/^I choose perfmon file$/) do
  pending
end

And(/^I Upload results$/) do
  pending
end

Then(/^I see success message$/) do
  pending
end

Then(/^I see success message "([^"]*)"$/) do |arg|
  pending
end

Then(/^I see error message "([^"]*)"$/) do |arg|
  pending
end