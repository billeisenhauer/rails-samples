module SitesHelper
  
  def display_site_descendants(site)
    display_site_descendants_hash(site.descendants.arrange)
  end
  
  def display_site_with_depth(site)
    site.ancestry_depth > 0 ? "—" * site.ancestry_depth +  " #{site.name}" : site.name
  end
  
  def possible_parent_sites_for(site)
    current_user.visible_sites - [site]
  end
  
  def can_edit_parent?(site)
    return true if site.new_record?
    return false if current_user.site == site
    return false if possible_parent_sites_for(site).one?
    true
  end
  
  protected
  
    def display_site_descendants_hash(descendants_hash)
      return "" unless descendants_hash.any?
      str = "<ul>"
      descendants_hash.keys.each do |parent|
        str << "<li>"
        str << parent.name
        str << display_site_descendants_hash(descendants_hash[parent])
        str << "</li>"
      end
      str << "</ul>"
      str
    end
  
end
