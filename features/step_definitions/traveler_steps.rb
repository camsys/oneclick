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

When(/^the UI mode is kiosk$/) do
  puts "the UI mode is kiosk"
  r = CsHelpers::ui_mode_kiosk?
  puts "result is #{r.inspect}"
  r
end

### THEN ###
Then(/^I see "Touch to begin"$/) do
  if CsHelpers::ui_mode_kiosk?
    page.should have_content "Touch to begin" 
  end
end

Then(/^I see "(.*?)"$/) do |arg1|
  page.should have_content arg1
end

# none
