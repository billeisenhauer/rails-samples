Factory.define(:tag) do |tag|
  tag.association :site
  tag.sequence(:tag_number) { |n| "100.100.100.#{n}" }
end