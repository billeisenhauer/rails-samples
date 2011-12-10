Factory.define(:notification_specification) do |ns|
  ns.association :site
  ns.association :user
  ns.sequence(:name) { |n| "NS #{n}" }
end