class TagsController < ApplicationController
  
  before_filter :require_user
  before_filter :record_last_page, :only => [:index]
  before_filter :load_tag, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all, :attribute_check => false
  
  ### LIST ###
  
  def index
    @list_options = load_list_options
    @tags = Tag.filter(@list_options).paginate(:page => params[:page], :per_page => 15)
  end

  ### CREATE ###
  
  def new
    @tag = Tag.new(:site => current_user.site)
  end
  
  def create
    @tag = Tag.new(params[:tag])
    @tag.save!
    flash[:notice] = "Successfully created tag."
    redirect_to session[:tags_last_page] || tags_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end  

  ### UPDATE ###
  
  def update
    @tag.update_attributes!(params[:tag])
    flash[:notice] = "Successfully updated tag."
    redirect_to session[:tags_last_page] || tags_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  ### DESTROY ###
  
  def destroy
    @tag.destroy
    flash[:notice] = "Successfully deleted tag."
    redirect_to last_tags_path
  end  

  ### BULK ###
  
  def bulk
    @tags = Tag.find(params[:tag_ids])
    apply_bulk_actions if params[:bulk_action_change]
    apply_bulk_site_changes if params[:bulk_site_change]
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "No tags were selected; nothing has been done."  
  ensure
    redirect_to last_tags_path
  end
  
  ### IMPORT ###
  
  def import
    # TODO
  end
    
  ### MISCELLANEOUS ###  
    
  def last_tags_path
    session[:tags_last_page] || tags_path
  end
  helper_method :last_tags_path  
    
  protected
  
    def load_tag
      @tag = Tag.find(params[:id])
    end
    
    def load_list_options
      params.delete(:search) if params[:search_action] == 'Clear'
      params.delete(:search_action)
      options = {:for_site => current_user.site, :sorted_by => 'tag_number'}
      Tag.list_option_names.each do |name|
        options[name] = params[name] unless params[name].blank?
      end
      options
    end
    
    def apply_bulk_actions
      if params[:bulk_action].blank?
        flash[:error] = "No action was selected; nothing has been done."
      elsif params[:bulk_action] == 'delete'
        Tag.transaction do
          @tags.each { |tag| tag.destroy }
          flash[:notice] = "Successfully deleted #{@tags.size} tags."
        end
      end
    end
    
    def apply_bulk_site_changes
      site = Site.find(params[:bulk_site])
      Tag.transaction do
        @tags.each { |tag| tag.update_attributes(:site_id => site.id) }
        flash[:notice] = "Successfully assigned #{@tags.size} tags to #{site.name}."
      end
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Don't know that site; nothing has been done."
    end
  
end
