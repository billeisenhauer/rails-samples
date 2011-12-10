class NotificationsController < ApplicationController
  
  before_filter :require_user
  before_filter :record_last_page, :only => [:index]
  before_filter :load_spec, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all, :attribute_check => false
  
  ### LIST ###
  
  def index
    @list_options = load_list_options
    @specs = NotificationSpecification.filter(@list_options).paginate(:page => params[:page], :per_page => 15)
  end

  ### CREATE ###
  
  def new
    @spec = NotificationSpecification.new(:user => current_user)
  end
  
  def create
    strip_commas_and_currency_symbols_from_amounts
    @spec = NotificationSpecification.new(params[:notification_specification])
    @spec.user = current_user
    @spec.save!
    flash[:notice] = "Successfully created notification."
    redirect_to session[:notifications_last_page] || notifications_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end  

  ### UPDATE ###
  
  def update
    strip_commas_and_currency_symbols_from_amounts
    @spec.update_attributes!(params[:notification_specification])
    flash[:notice] = "Successfully updated notification."
    redirect_to session[:notifications_last_page] || notifications_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  ### DESTROY ###
  
  def destroy
    @spec.destroy
    flash[:notice] = "Successfully deleted notification."
    redirect_to last_notifications_path
  end  

  ### BULK ###
  
  def bulk
    @specs = NotificationSpecification.find(params[:spec_ids])
    apply_bulk_actions if params[:bulk_action_change]
    apply_bulk_site_changes if params[:bulk_site_change]
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "No notifications were selected; nothing has been done."
  ensure
    redirect_to last_notifications_path
  end
    
  ### MISCELLANEOUS ###  
    
  def last_notifications_path
    session[:notifications_last_page] || notifications_path
  end
  helper_method :last_notifications_path  
    
  protected
  
    def load_spec
      @spec = NotificationSpecification.find(params[:id])
    end
    
    def load_list_options
      params.delete(:search) if params[:search_action] == 'Clear'
      params.delete(:search_action)
      options = {:sorted_by => 'name'}
      NotificationSpecification.list_option_names.each do |name|
        options[name] = params[name] unless params[name].blank?
      end
      options
    end
    
    def apply_bulk_actions
      if params[:bulk_action].blank?
        flash[:error] = "No action was selected; nothing has been done."
      elsif params[:bulk_action] == 'delete'
        NotificationSpecification.transaction do
          @specs.each { |spec| spec.destroy }
          flash[:notice] = "Successfully deleted #{@specs.size} notifications."
        end
      end
    end
    
    def apply_bulk_site_changes
      site = Site.find(params[:bulk_site])
      NotificationSpecification.transaction do
        @specs.each { |spec| spec.update_attributes(:site_id => site.id) }
        flash[:notice] = "Successfully assigned #{@specs.size} notifications to #{site.name}."
      end
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Don't know that site; nothing has been done."
    end
  
    def strip_commas_and_currency_symbols_from_amounts
      return unless params[:notification_specification]
      condition_params = params[:notification_specification][:notification_conditions_attributes]
      return unless condition_params
      condition_params.keys.each do |key|
        condition_params[key]['value'].gsub!(/\$|,/, '') if condition_params[key]['field'] =~ /.*_amount$/
      end
    end
  
end
