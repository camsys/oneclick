### UTILITY METHODS ###

# none

### WHEN ###

When /^I look at the home page$/ do
  visit '/'
end

### THEN ###
Then(/^I see "(.*?)"$/) do |arg1|
  page.should have_content arg1
end

# none
