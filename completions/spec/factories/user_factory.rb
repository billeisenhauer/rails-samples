Factory.define(:user) do |user|
  user.sequence(:username) { |n| "user#{n}" }
  user.email { Faker::Internet.email }
  user.name  { Faker::Name.name }
end

Factory.define(:guest_user, :class => User, :parent => :user) do |user|
  user.role { |role| role.association(:guest_role) } 
end

Factory.define(:champion_user, :class => User, :parent => :user) do |user|
  user.role { |role| role.association(:champion_role) } 
end

Factory.define(:administrator_user, :class => User, :parent => :user) do |user|
  user.role { |role| role.association(:administrator_role) } 
end

Factory.define(:support_administrator_user, :class => User, :parent => :user) do |user|
  user.role { |role| role.association(:support_administrator_role) } 
end