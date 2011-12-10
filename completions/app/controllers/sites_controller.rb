class SitesController < ApplicationController
  
  before_filter :require_user
  before_filter :record_last_page, :only => [:index]
  before_filter :load_site, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all, :attribute_check => false
  
  ### LIST ###
  
  def index
    @list_options = load_list_options
    @sites = Site.filter(@list_options).paginate(:page => params[:page], :per_page => 15)
  end

  ### CREATE ###
  
  def new
    @site = Site.new
  end
  
  def create
    @site = Site.new(params[:site])
    @site.save!
    flash[:notice] = "Successfully created site."
    redirect_to session[:sites_last_page] || sites_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end  

  ### UPDATE ###
  
  def update
    @site.update_attributes!(params[:site])
    flash[:notice] = "Successfully updated site."
    redirect_to session[:sites_last_page] || tags_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  ### DESTROY ###
  
  def destroy
    @site.destroy
    flash[:notice] = "Successfully deleted site."
    redirect_to last_sites_path
  end  

  ### BULK ###
  
  def bulk
    @sites = Site.find(params[:site_ids])
    apply_bulk_actions if params[:bulk_action_change]
  rescue ActiveRecord::RecordNotFound  
    flash[:error] = "No sites were selected; nothing has been done."
  ensure
    redirect_to last_sites_path
  end
    
  ### MISCELLANEOUS ###  
    
  def last_sites_path
    session[:sites_last_page] || sites_path
  end
  helper_method :last_sites_path  
    
  protected
  
    def load_site
      @site = Site.find(params[:id])
    end
    
    def load_list_options
      params.delete(:search) if params[:search_action] == 'Clear'
      params.delete(:search_action)
      options = {:for_site => current_user.site, :sorted_by => 'ancestry_names'}
      Site.list_option_names.each do |name|
        options[name] = params[name] unless params[name].blank?
      end
      options
    end
    
    def apply_bulk_actions
      if params[:bulk_action].blank?
        flash[:error] = "No action was selected; nothing has been done."
      elsif params[:bulk_action] == 'delete'
        Site.transaction do
          @sites.each { |site| site.destroy }
          flash[:notice] = "Successfully deleted #{@sites.size} sites."
        end
      end
    end
  
end
