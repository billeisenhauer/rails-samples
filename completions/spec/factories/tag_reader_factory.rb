Factory.define(:tag_reader) do |tag_reader|
  tag_reader.association :site
  tag_reader.sequence(:reader) { |n| "GF-Reader-#{n}" }
  tag_reader.sequence(:address) { |n| "Houma Location - #{n}" }
end