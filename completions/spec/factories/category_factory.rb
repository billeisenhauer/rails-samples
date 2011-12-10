Factory.define(:category) do |c|
  c.association :site
  c.sequence(:name) { |n| "Category #{n}" }
end