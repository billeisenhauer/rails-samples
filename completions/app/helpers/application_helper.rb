module ApplicationHelper
  
  ### LAYOUT HELPERS ###
  
  def page_title
    @page_title ?  "#{@page_title} | #{AppConfig.app_name}" : AppConfig.app_name
  end
  
  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args.map(&:to_s)) }
  end
  
  def javascript(*args)
    args = args.map { |arg| arg == :defaults ? arg : arg.to_s }
    content_for(:head) { javascript_include_tag(*args) }
  end  
  
  ### CSS HELPERS ###
  
  # Determines the body id based upon the current page value placed in the
  # page or by the name of the controller and action.
  def body_id
    derived_body_id = params[:controller].gsub(/(\/|_)/, '-')
    @body_id || derived_body_id
  end
  
  def current_menu(controller)
    controller == params[:controller] ? 'current' : ''  
  end
  
  def folded_menu_class
    session[:foldmenu] ? 'folded' : ''
  end
  
  ### MISCELLANEOUS ###
  
  def search_param?
    params[:search] && params[:search].any?
  end
  
  def sortable_heading(label, field, make_link, default_sorted_by = nil)
    sorted_by = params[:sorted_by] || default_sorted_by
    if sorted_by
      order, direction = sorted_by.split(' ')    
      class_name = (field == order ? "sort-#{direction}-link" : '')
    end
    class_name ||= ''
    if order == field
      direction = (direction == 'asc' ? 'desc' : 'asc')
    else
      direction = 'asc'
    end
    new_params = params.merge(:sorted_by => [field, direction].join(' '))
    link_to(label, make_link.call(new_params), :class => class_name)
  end
  
  def last_inventory_assets_path
    session[:inventory_assets_last_page] || inventory_assets_path
  end
  
  def last_users_path
    session[:users_last_page] || users_path
  end
  
  def last_reported_at_for(object)
    object.last_reported_at ? object.last_reported_at.to_s(:us_with_time) : 'Never'
  end
  
  def parameterized_link
    path_method = "#{controller_name}_path"
    proc { |params| send(path_method, :params => params) } 
  end
  
  ### USERS / PROFILE ###
  
  def can_edit_site?(user)
    current_user != user || permitted_to?(:update, :users)
  end
  
  def can_edit_role?(user)
    permitted_to?(:update, :users)
  end
  
  def mmddyy(date)
    date ? date.to_s(:mmddyy) : 'None'
  end
  
  ### CHILD ROW SUPPORT ###
  
  def remove_recipient_child_link(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_recipient_fields(this)")
  end

  def add_recipient_child_link(name, f, method)
    fields = new_child_fields(f, method)
    link_to_function(name, h("insert_recipient_fields(this, \"#{method}\", \"#{escape_javascript(fields)}\")"))
  end  
  
  def remove_child_link(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def add_child_link(name, f, method)
    fields = new_child_fields(f, method)
    link_to_function(name, h("insert_fields(this, \"#{method}\", \"#{escape_javascript(fields)}\")"))
  end
  
  def new_child_fields(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f
    form_builder.fields_for(method, options[:object], :child_index => "new_#{method}") do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
  end
  
  def current_user?
    current_user && current_user.site
  end
  
end
