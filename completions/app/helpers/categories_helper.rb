module CategoriesHelper
  
  def display_category_descendants(category)
    display_category_descendants_hash(category.descendants.arrange)
  end
  
  def display_category_with_depth(category)
    category.ancestry_depth > 0 ? "—" * category.ancestry_depth +  " #{category.name}" : category.name
  end
  
  def possible_parent_categories_for(category)
    current_user.site.all_categories - [category]
  end
  
  def can_edit_parent?(category)
    return true if category.new_record?
    return false if possible_parent_categories_for(category).one?
    true
  end
  
  protected
  
    def display_category_descendants_hash(descendants_hash)
      return "" unless descendants_hash.any?
      str = "<ul>"
      descendants_hash.keys.each do |parent|
        str << "<li>"
        str << parent.name
        str << display_category_descendants_hash(descendants_hash[parent])
        str << "</li>"
      end
      str << "</ul>"
      str
    end
  
end
