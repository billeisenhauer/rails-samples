class TagReadersController < ApplicationController

  before_filter :require_user
  before_filter :record_last_page, :only => [:index]
  before_filter :load_tag_reader, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all, :attribute_check => false
  
  ### LIST ###
  
  def index
    @list_options = load_list_options
    @tag_readers = TagReader.filter(@list_options).paginate(:page => params[:page], :per_page => 15)
  end

  ### CREATE ###
  
  def new
    @tag_reader = TagReader.new
  end
  
  def create
    @tag_reader = TagReader.new(params[:tag_reader])
    @tag_reader.save!
    flash[:notice] = "Successfully created tag reader."
    redirect_to session[:tag_readers_last_page] || tag_readers_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end  

  ### UPDATE ###
  
  def update
    @tag_reader.update_attributes!(params[:tag_reader])
    flash[:notice] = "Successfully updated tag reader."
    redirect_to session[:tag_readers_last_page] || tag_readers_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  ### DESTROY ###
  
  def destroy
    @tag_reader.destroy
    flash[:notice] = "Successfully deleted tag reader."
    redirect_to last_tag_readers_path
  end  

  ### BULK ###
  
  def bulk
    @tag_readers = TagReader.find(params[:tag_reader_ids])
    apply_bulk_actions if params[:bulk_action_change]
    apply_bulk_site_changes if params[:bulk_site_change]
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "No tag readers were selected; nothing has been done."
  ensure
    redirect_to last_tag_readers_path
  end
    
  ### MISCELLANEOUS ###  
    
  def last_tag_readers_path
    session[:tag_readers_last_page] || tag_readers_path
  end
  helper_method :last_tag_readers_path  
    
  protected
  
    def load_tag_reader
      @tag_reader = TagReader.find(params[:id])
    end
    
    def load_list_options
      params.delete(:search) if params[:search_action] == 'Clear'
      params.delete(:search_action)
      options = {:for_site => current_user.site, :sorted_by => 'reader'}
      TagReader.list_option_names.each do |name|
        options[name] = params[name] unless params[name].blank?
      end
      options
    end
    
    def apply_bulk_actions
      if params[:bulk_action].blank?
        flash[:error] = "No action was selected; nothing has been done."
      elsif params[:bulk_action] == 'delete'
        TagReader.transaction do
          @tag_readers.each { |tag_reader| tag_reader.destroy }
          flash[:notice] = "Successfully deleted #{@tag_readers.size} tag readers."
        end
      end
    end
    
    def apply_bulk_site_changes
      site = Site.find(params[:bulk_site])
      TagReader.transaction do
        @tag_readers.each { |tag_reader| tag_reader.update_attributes(:site_id => site.id) }
        flash[:notice] = "Successfully assigned #{@tag_readers.size} tag readers to #{site.name}."
      end
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Don't know that site; nothing has been done."
    end

end
