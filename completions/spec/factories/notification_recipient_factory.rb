Factory.define(:notification_recipient) do |nr|
  nr.association :user
  nr.association :notification_specification
end