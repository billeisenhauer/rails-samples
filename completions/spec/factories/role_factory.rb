Factory.define(:role) do |role|
  role.sequence(:name) { |n| "Role #{n}" }
end

Factory.define(:guest_role, :class => Role) do |role|
  role.name 'Guest'
end

Factory.define(:champion_role, :class => Role) do |role|
  role.name 'Champion'
end

Factory.define(:administrator_role, :class => Role) do |role|
  role.name 'Administrator'
end

Factory.define(:support_administrator_role, :class => Role) do |role|
  role.name 'Support Administrator'
end