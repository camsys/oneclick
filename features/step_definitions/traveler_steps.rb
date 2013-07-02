### UTILITY METHODS ###

# none

### WHEN ###

When /^I look at the home page$/ do
  visit '/'
end

### THEN ###
Then(/^I see "(.*?)"$/) do |arg1|
  ['Plan a trip', 'Identify Places', 'Change My Settings', 'Help & Support'].include? arg1
end

# none
