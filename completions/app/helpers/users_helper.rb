module UsersHelper
  
  def bulk_actions_options
    options_for_select([["Bulk Actions", ""], ["Delete", "delete"]])
  end
  
  def bulk_roles_options
    options_from_collection_for_select(Role.all, 'id', 'name')
  end
  
  def sites_for(user)
    return '&nbsp;' unless user.sites.any?
    user.sites.map(&:name).join(', ')
  end
  
  def last_login_at_for(user)
    return 'Never' unless user
    if user.last_login_at
      user.last_login_at.to_s(:us_with_time)
    elsif user.last_request_at
      user.last_request_at.to_s(:us_with_time)
    else  
      'Never'
    end
  end
  
end
