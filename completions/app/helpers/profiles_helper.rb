module ProfilesHelper
  
  def assignable_roles_for(user)
    if user.role_name == 'Support Administrator'
      Role.all
    else
      Role.assignable_roles
    end
  end
  
end
