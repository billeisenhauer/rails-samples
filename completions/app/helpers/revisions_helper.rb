module RevisionsHelper
  
  def asset_name_for(asset)
    asset.po_number || asset.rfq_number
  end
  
  def field_value_for(key, value)
    case key
      when 'pe_id'
        User.find(value).display_name rescue "'unknown'"
      when 'site_id'
        Site.find(value).ancestry_names rescue "'unknown'"
      when 'tag_id'
        Tag.find(value).tag_number rescue "'unknown'"
      when 'category_id'
        Category.find(value).ancestry_names rescue "'unknown'"
      when 'gr'
        value ? "'YES'" : "'NO'"
      else
        "'#{value}'"
    end
  end
  
  def user_link_for(audit) 
    username = audit.user && audit.user.username
    username ? link_to(username, user_path(username)) : 'system'
  end
  
end
