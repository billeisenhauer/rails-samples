module TagsHelper
  
  def bulk_actions_options
    options_for_select([["Bulk Actions", ""], ["Delete", "delete"]])
  end
  
  def bulk_sites_options
    options_from_collection_for_select(current_user.visible_sites, 'id', 'name')
  end
  
end
