class CategoriesController < ApplicationController
  
  before_filter :require_user
  before_filter :record_last_page, :only => [:index]
  before_filter :load_category, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all, :attribute_check => false
  
  ### LIST ###
  
  def index
    @list_options = load_list_options
    @categories = Category.filter(@list_options).paginate(:page => params[:page], :per_page => 15)
  end

  ### CREATE ###
  
  def new
    @category = Category.new(:site => current_user.site)
  end
  
  def create
    @category = Category.new(params[:category])
    @category.save!
    flash[:notice] = "Successfully created category."
    redirect_to session[:categories_last_page] || categories_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end  

  ### UPDATE ###
  
  def update
    @category.update_attributes!(params[:category])
    flash[:notice] = "Successfully updated category."
    redirect_to session[:categories_last_page] || categories_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  ### DESTROY ###
  
  def destroy
    @category.destroy
    flash[:notice] = "Successfully deleted category."
    redirect_to last_categories_path
  end  

  ### BULK ###
  
  def bulk
    @categories = Category.find(params[:category_ids])
    apply_bulk_actions if params[:bulk_action_change]
    apply_bulk_site_changes if params[:bulk_site_change]
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "No categories were selected; nothing has been done."
  ensure
    redirect_to last_categories_path
  end
    
  ### MISCELLANEOUS ###  
    
  def last_categories_path
    session[:categories_last_page] || categories_path
  end
  helper_method :last_categories_path  
    
  protected
  
    def load_category
      @category = Category.find(params[:id])
    end
    
    def load_list_options
      params.delete(:search) if params[:search_action] == 'Clear'
      params.delete(:search_action)
      options = {:for_site => current_user.site, :sorted_by => 'ancestry_names asc'}
      Category.list_option_names.each do |name|
        options[name] = params[name] unless params[name].blank?
      end
      options
    end
    
    def apply_bulk_actions
      if params[:bulk_action].blank?
        flash[:error] = "No action was selected; nothing has been done."
      elsif params[:bulk_action] == 'delete'
        Category.transaction do
          @categories.each { |category| category.destroy }
          flash[:notice] = "Successfully deleted #{@categories.size} categories."
        end
      end
    end
    
    def apply_bulk_site_changes
      site = Site.find(params[:bulk_site])
      Category.transaction do
        @categories.each { |category| category.update_attributes(:site_id => site.id) }
        flash[:notice] = "Successfully assigned #{@categories.size} categories to #{site.name}."
      end
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Don't know that site; nothing has been done."
    end
  
end
