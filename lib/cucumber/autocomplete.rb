Given /^I choose "([^"]*)" in the autocomplete list$/ do |text|
  page.execute_script %Q{ $('input[data-autocomplete]').trigger("focus") }
  page.execute_script %Q{ $('input[data-autocomplete]').trigger("keydown") }
  sleep 1
  page.execute_script %Q{ $('.ui-menu-item a:contains("#{text}")').trigger("mouseenter").trigger("click"); }
end

Then /^I should (see|not see) "([^"]+)" in the autocomplete list$/ do |see_or_not, text|
  Then "I should #{see_or_not} \"#{text}\" within \"ul.ui-autocomplete.ui-menu\""
end

Then /^I should see "([^"]+)" elements? in the autocomplete list$/ do |nbr|
  page.should have_xpath("//div[@id='activity_dialog']//ul/li", :count => nbr.to_i)
end
