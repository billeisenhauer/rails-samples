Given /^the following sites:$/ do |table|
  table.rows.each do |id, name, ancestry|
    Factory(:site, :id => id, :name => name, :ancestry => ancestry)
  end
end

Given /^the following site memberships:$/ do |table|
  table.rows.each do |user_id, site_id|
    Factory(:site_membership, :user_id => user_id, :site_id => site_id)
  end
end