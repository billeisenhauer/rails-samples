module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
      when /the home\s?page/
        '/'
    
      when /the signin page/
        '/signin'
      
      when /the users page/
        '/users'
      
      when /the new user page/
        '/users/new'
        
      when /the edit user sites page/
        '/user_sites/edit'
        
      when /the edit profile page/
        '/profile/edit'
      
      when /the tags page/
        '/tags'
      
      when /the new tag page/
        '/tags/new'
        
      when /the show page for (.+)/
        polymorphic_path(model($1))

      when /the edit page for (.+)/
        polymorphic_path(model($1))
        
      when /path "(.+)"/
        $1

    
      # Add more mappings here.
      # Here is a more fancy example:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

      else
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
              "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
