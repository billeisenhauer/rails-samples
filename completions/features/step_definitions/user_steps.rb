### GIVEN ###

Given /^the following users:$/ do |table|
  table.rows.each do |id, username, password|
    Factory(:user, :id => id, :username => username)
  end
end

Given /^I am a registered user$/ do
  user
end

Given /^I am signed in as "([^"]*)"$/ do |username|
  user = User.find_by_username(username)
  login(user)
end

Given /^I am signed in$/ do
  login(user)
end

Given /^I am signed in as "([^"]*)" user$/ do |role_name|
  @user = Factory.create(:user, :role => Role.find_by_name(role_name))
  login(@user)
end

Given /^I have users with username (.+)$/ do |usernames|
  usernames.split(', ').each do |u|
    User.create!(:username => u)
  end
end

Given /^I am requesting ([^"]*) page with username "([^"]*)"$/ do |model, username|
  visit polymorphic_path(record_from_strings(model,username))
end

### THEN ###

Then /^I should have ([0-9]+) users$/ do |count|
  User.count.should == count.to_i
end

Then /^I should see users table$/ do |expected_table|
  html_tabl = table_at("#users").to_a
  html_table.map! { |r| r.map! { |c| c.gsub(/<.+?/, '') } }
  expected_table.diff!(html_table)
end

# 
# Transform /^table:id,name,ancestry$/ do |table|
#   table.hashes.map { |hash| hash[:ancestry] }.map {|ancestry| ancestry.empty? ? nil : ancestry }
# end

### WHEN ###

When /^I visit edit default site for "([^\"]*)"$/ do |username|
  user = User.find_by_username!(username)
  visit edit_site_user_path(user)
end

### HELPERS ###

def user
  @user ||= Factory(:user)
end

def specific_user(username)
  @user ||= Factory(:user, :username => username)
end

def login(user)
  visit path_to("the signin page")
  fill_in "Username", :with => user.username
  fill_in "Password", :with => 'password'
  click_button "Sign In"
  response.should contain("Sign in successful!")
  response.should contain("Sign Out")
end

def record_from_strings(model, username)
  model.constantize.find(:first, :conditions => ['username = ?', username])
end