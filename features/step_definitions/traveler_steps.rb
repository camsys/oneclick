### UTILITY METHODS ###

# none

### WHEN ###

When /^I look at the home page$/ do
  visit '/'
end

When(/^the UI mode is not kiosk$/) do
  puts "the UI mode is not kiosk"
  r = !CsHelpers::ui_mode_kiosk?
  puts "result is #{r.inspect}"
  r
end

### THEN ###
Then(/^I see "Plan a Trip" or "Touch to begin"$/) do
  if CsHelpers::ui_mode_kiosk?
    arg1 = "Touch to begin" 
  else
    arg1 = "Plan a Trip" 
  end
  page.should have_content arg1
end

Then(/^I see "(.*?)"$/) do |arg1|
  page.should have_content arg1
end

# none
