### GIVEN ###

Given /^the following tags:$/ do |table|
  table.rows.each do |id, tag_number|
    Factory(:tag, :id => id, :tag_number => tag_number)
  end
end

Given /^I am requesting ([^"]*) page with id "([^"]*)"$/ do |model, id|
  visit polymorphic_path(record_from_strings(model, id))
end

### THEN ###

Then /^I should see tags table$/ do |expected_table|
  html_tabl = table_at("#tags").to_a
  html_table.map! { |r| r.map! { |c| c.gsub(/<.+?/, '') } }
  expected_table.diff!(html_table)
end

### HELPERS ###

def record_from_strings(model, id)
  model.constantize.find(id)
end