Factory.define(:site) do |site|
  site.sequence(:name) { |n| "Site #{n}" }
end