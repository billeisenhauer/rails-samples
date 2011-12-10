class ApplicationController < ActionController::Base
  
  before_filter :set_current_user 
  before_filter :set_timezone
  before_filter :handle_menu_folding
  
  helper :all 
  helper_method :current_user_session, :current_user, :logged_in?
  
  protect_from_forgery 

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  ### RENDER HELPERS ###
  
  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  
  def render_not_found(exception = nil)
    render :template => 'errors/notfound'
  end  
  
  ### CURRENT USER ###
  
  def logged_in?
    !! current_user
  end
  
  def permission_denied
    redirect_to unauthorized_path
  end

  protected
  
    def set_current_user
      Authorization.current_user = current_user
    end
  
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def require_user
      unless current_user
        store_location
        if current_user_session && current_user_session.stale?
          flash[:error] = 'Your session has timed out.  Please sign in again.'
        end
        redirect_to signin_path
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:error] = "You must be signed out to access this page"
        redirect_to inventory_assets_path
        return false
      end
    end
    
    def require_site_membership
      unless current_user.sites.any?
        redirect_to site_membership_required_path 
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    def handle_menu_folding
      return true unless params[:unfoldmenu]
      params[:unfoldmenu] =
      session[:foldmenu] = !(!! session[:foldmenu])
      true
    end
    
    def record_last_page
      key = "#{params[:controller]}_last_page".to_sym
      session[key] = request.request_uri if request.get?
      true
    end
    
    def home_url
      url = inventory_assets_url if permitted_to?(:show, :inventory_assets)
      url ||= tags_url if permitted_to?(:show, :tags)
      url ||= unauthorized_path
      url
    end

    def set_timezone
      Time.zone = current_user.time_zone if current_user
    end
    
end
