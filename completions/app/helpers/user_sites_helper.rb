module UserSitesHelper
  
  def sites_options_for(user)
    options_from_collection_for_select(user.sites, 'id', 'name')
  end
  
end
