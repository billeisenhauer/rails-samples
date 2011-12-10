class UsersController < ApplicationController
  
  before_filter :require_user
  before_filter :record_last_page, :only => :index
  before_filter :load_user, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all, :attribute_check => false
  
  ### LIST ###
  
  def index
    @list_options = load_list_options
    @users = User.filter(@list_options).paginate(:page => params[:page], :per_page => 15)
  end

  ### CREATE ###
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.save!
    flash[:notice] = "Successfully created user."
    redirect_to session[:users_last_page] || users_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  ### UPDATE ###
  
  def update
    @user.update_attributes!(params[:user])
    flash[:notice] = "Successfully updated user."
    redirect_to session[:users_last_page] || users_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  ### DESTROY ###
  
  def destroy
    @user.destroy
    flash[:notice] = "Successfully deleted user."
    redirect_to last_users_path
  end
  
  ### BULK ###
  
  def bulk
    @users = User.find(params[:user_ids])
    apply_bulk_actions if params[:bulk_action_change]
    apply_bulk_role_changes if params[:bulk_role_change]
  rescue ActiveRecord::RecordNotFound  
    flash[:error] = "No users were selected; nothing has been done."
  ensure
    redirect_to last_users_path
  end
  
  def last_users_path
    session[:users_last_page] || users_path
  end
  helper_method :last_users_path
  
  protected
  
    def load_user
      @user = User.find_by_username(params[:id])
    end
    
    def load_list_options
      params.delete(:search) if params[:search_action] == 'Clear'
      params.delete(:search_action)
      options = {:for_site => current_user.site, :sorted_by => 'username asc'}
      options.delete(:for_site) if params[:unauthorized]
      User.list_option_names.each do |name|
        options[name] = params[name] unless params[name].blank?
      end
      options
    end
    
    def apply_bulk_actions
      if params[:bulk_action].blank?
        flash[:error] = "No action was selected; nothing has been done."
      elsif params[:bulk_action] == 'delete'
        User.transaction do
          @users.each { |user| user.destroy }
          flash[:notice] = "Successfully deleted #{@users.size} users."
        end
      end
    end
    
    def apply_bulk_role_changes
      role = Role.find(params[:bulk_role])
      User.transaction do
        @users.each { |user| user.update_attributes(:role => role) }
        flash[:notice] = "Successfully granted #{role.name} role to #{@users.size} users."
      end
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Don't know that role; nothing has been done."
    end
  
end
