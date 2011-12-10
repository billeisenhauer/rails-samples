# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  ### LAYOUT HELPERS ###
  
  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args.map(&:to_s)) }
  end
  
  def javascript(*args)
    args = args.map { |arg| arg == :defaults ? arg : arg.to_s }
    content_for(:head) { javascript_include_tag(*args) }
  end
  
  def title(page_title)
    content_for(:title) { "#{AppConfig.app_name} &#8212; #{AppConfig.app_title} &#8212; #{page_title}" }
  end
  
  def description(description)
    content_for(:description) { description }
  end
  
  def keywords(keywords)
    content_for(:keywords) { keywords }
  end
  
  ### CSS HELPERS ###
  
  def body_id
    derived_body_id = params[:controller].gsub('/', '-')
    if params[:controller] == 'pages'
      if params[:page]
        derived_body_id += "-#{params[:page]}"
      else
        derived_body_id += '-home'
      end
    end
    @body_id || derived_body_id
  end
  
  def body_class
    derived_body_class = params[:controller].gsub('/', '-')
    @body_class || derived_body_class
  end
  
  ### MISCELLANEOUS ###
  
  def current_year
    Date.today.year
  end
  
end
