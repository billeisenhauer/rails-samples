Given /^the system roles$/ do
  [:guest_role, :champion_role, :administrator_role, :support_administrator_role].each do |role|
    Factory.create(role)
  end
end

Given /^the following roles:$/ do |table|
  table.rows.each do |name|
    Factory(:role, :name => name)
  end
end