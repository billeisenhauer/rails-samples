Factory.define :site_membership do |f|
  f.association :site
  f.association :user
end
