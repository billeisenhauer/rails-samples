Factory.define(:inventory_asset) do |f|
  f.site { |site| site.association(:site) }
  f.sequence(:po_number) { |n| "12345#{n}" }
  f.sequence(:serial_number) { |n| "99999#{n}" }
  f.ordered_on 45.days.ago
end

Factory.define(:yellow, :class => InventoryAsset, :parent => :inventory_asset) do |asset|
  asset.gr    true
  asset.gr_on 25.days.ago
end

Factory.define(:green, :class => InventoryAsset, :parent => :yellow) do |asset|
  asset.fo    true
  asset.fo_on 15.days.ago
end

Factory.define(:blue, :class => InventoryAsset, :parent => :green) do |asset|
  asset.installed_on Date.today
end

Factory.define(:archived, :class => InventoryAsset, :parent => :blue) do |asset|
  asset.ordered_on   120.days.ago
  asset.gr_on        90.days.ago
  asset.fo_on        80.days.ago
  asset.installed_on 70.days.ago
end