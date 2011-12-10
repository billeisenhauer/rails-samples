class InventoryAssetsController < ApplicationController
  
  before_filter :require_user
  before_filter :record_last_page, :only => :index
  before_filter :load_inventory_asset, :only => [:show, :edit, :update, :destroy, :new_split]
  before_filter :set_per_page
  filter_access_to :all, :attribute_check => false
  
  ### LIST ###
  
  def index
    @list_options = load_list_options
    @inventory_assets = InventoryAsset.filter(@list_options).paginate(:page => params[:page], :per_page => per_page_preference)
    get_filter_counts
  end
  
  ### EXPORT
  
  def export
    export_csv = InventoryAsset.export(load_list_options)
    send_data(export_csv, :filename => 'scims-export.csv', :type => 'text/csv', :disposition => 'attachment')
  end
  
  ### IMPORT ###
  
  def sample_import
    send_file('public/sample-import.csv', :filename => 'sample-import.csv', :type => 'text/csv', :disposition => 'attachment' )
  end
  
  def new_import
    @import = Import.new
  end
  
  def import
    @import = Import.new(params[:import])
    @import.save!
    flash[:notice] = "#{@import.imported_rows} imported assets.  #{@import.rejected_rows} rejected assets."
    redirect_to inventory_assets_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'new_import'
  end
  
  ### DOWNLOAD ###
  
  SEND_FILE_METHOD = :default
  
  def download
    head(:not_found) and return if (inventory_asset = InventoryAsset.find_by_id(params[:id])).nil?
    head(:forbidden) and return unless inventory_asset.downloadable_by?(current_user)

    path = inventory_asset.attachment.path(params[:basename])
    head(:bad_request) and return unless File.exist?(path) && params[:format].to_s == File.extname(path).gsub(/^\.+/, '')

    send_file_options = { :type => File.mime_type?(path) }

    case SEND_FILE_METHOD
      when :apache then send_file_options[:x_sendfile] = true
#      when :nginx then head(:x_accel_redirect => path.gsub(Rails.root, ''), :content_type => send_file_options[:type]) and return
    end

    send_file(path, send_file_options)
  end

  ### CREATE ###
  
  def new
    @inventory_asset = InventoryAsset.new(:site => current_user.site)
  end
  
  def create
    strip_commas_and_currency_symbols_from_amounts
    @inventory_asset = InventoryAsset.new(params[:inventory_asset])
    if @inventory_asset.original_lot?
      create_verb = 'created'
      @inventory_asset.save!
    else
      create_verb = 'split'
      @inventory_asset.split!
    end
    flash[:notice] = "Successfully #{create_verb} inventory asset."
    render :action => 'edit'
  rescue ActiveRecord::RecordInvalid
    @current_link = params[:current_link]
    render :action => 'new'
  end
  
  ### UPDATE ###
  
  def update
    strip_commas_and_currency_symbols_from_amounts
    @inventory_asset.update_attributes!(params[:inventory_asset])
    flash[:notice] = "Successfully updated inventory asset."
    render :action => 'edit'
  rescue ActiveRecord::RecordInvalid
    @current_link = params[:current_link]
    render :action => 'edit'
  end
  
  ### SPLIT ###
  
  def new_split
    @split_inventory_asset = InventoryAsset.split_from(@inventory_asset)
  end
  
  ### DESTROY ###
  
  def destroy
    @inventory_asset.destroy
    flash[:notice] = "Successfully deleted inventory asset."
    redirect_to last_inventory_assets_path
  end
  
  ### BULK ###
  
  def bulk
    @inventory_assets = InventoryAsset.find(params[:inventory_asset_ids])
    apply_bulk_actions if params[:bulk_action_change]
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "No inventory assets were selected; nothing has been done."
  ensure
    redirect_to last_inventory_assets_path
  end
  
  ### PER PAGE ###
  
  def per_page
    redirect_to last_inventory_assets_path
  end
  
  def last_inventory_assets_path
    session[:inventory_assets_last_page] || inventory_assets_path
  end
  
  protected
  
    def load_inventory_asset
      @inventory_asset = InventoryAsset.find(params[:id])
    end
  
    def load_list_options
      params.delete(:search) if params[:search_action] == 'Clear'
      params.delete(:search_action)
      options = {:for_site => current_user.site, :sorted_by => 'ordered_on'}
      params[:since] = 2.months.ago unless params[:since] || params[:older]
      InventoryAsset.list_option_names.each do |name|
        options[name] = params[name] unless params[name].blank?
      end
      options
    end
    
    def apply_bulk_actions
      if params[:bulk_action].blank?
        flash[:error] = "No action was selected; nothing has been done."
      elsif params[:bulk_action] == 'delete'
        InventoryAsset.transaction do
          @inventory_assets.each { |inventory_asset| inventory_asset.destroy }
          flash[:notice] = "Successfully deleted #{@inventory_assets.size} inventory assets."
        end
      end
    end
    
    def get_filter_counts
      if params[:search]
        @active_count   = InventoryAsset.for_site(current_user.site).since(2.months.ago).search(params[:search]).count
        @archived_count = InventoryAsset.for_site(current_user.site).older(2.months.ago).search(params[:search]).count
        if params[:older]
          @red_count      = InventoryAsset.for_site(current_user.site).older(2.months.ago).for_state('red').search(params[:search]).count 
          @yellow_count   = InventoryAsset.for_site(current_user.site).older(2.months.ago).for_state('yellow').search(params[:search]).count
          @green_count    = InventoryAsset.for_site(current_user.site).older(2.months.ago).for_state('green').search(params[:search]).count
          @blue_count     = InventoryAsset.for_site(current_user.site).older(2.months.ago).for_state('blue').search(params[:search]).count    
        else
          @red_count      = InventoryAsset.for_site(current_user.site).since(2.months.ago).for_state('red').search(params[:search]).count 
          @yellow_count   = InventoryAsset.for_site(current_user.site).since(2.months.ago).for_state('yellow').search(params[:search]).count
          @green_count    = InventoryAsset.for_site(current_user.site).since(2.months.ago).for_state('green').search(params[:search]).count
          @blue_count     = InventoryAsset.for_site(current_user.site).since(2.months.ago).for_state('blue').search(params[:search]).count          
        end
      else
        @active_count   = InventoryAsset.for_site(current_user.site).since(2.months.ago).count
        @archived_count = InventoryAsset.for_site(current_user.site).older(2.months.ago).count
        if params[:older]
          @red_count      = InventoryAsset.for_site(current_user.site).older(2.months.ago).for_state('red').count 
          @yellow_count   = InventoryAsset.for_site(current_user.site).older(2.months.ago).for_state('yellow').count
          @green_count    = InventoryAsset.for_site(current_user.site).older(2.months.ago).for_state('green').count
          @blue_count     = InventoryAsset.for_site(current_user.site).older(2.months.ago).for_state('blue').count          
        else
          @red_count      = InventoryAsset.for_site(current_user.site).since(2.months.ago).for_state('red').count 
          @yellow_count   = InventoryAsset.for_site(current_user.site).since(2.months.ago).for_state('yellow').count
          @green_count    = InventoryAsset.for_site(current_user.site).since(2.months.ago).for_state('green').count
          @blue_count     = InventoryAsset.for_site(current_user.site).since(2.months.ago).for_state('blue').count
        end
      end
    end
    
    def set_per_page
      session[:assets_per_page] = params[:per_page] if valid_per_page?
      session[:assets_per_page] ||= per_page_preference
    end
    
    def valid_per_page?
      !! (params[:per_page] && params[:per_page].to_i > 0)
    end
    
    def per_page_preference
      session[:assets_per_page] || 5
    end
    
    def strip_commas_and_currency_symbols_from_amounts
      amount_params = params[:inventory_asset].select {|a| a.first =~ /.*_amount$/ }
      amount_params.each { |p| p.last.gsub!(/\$|,/, '') }
    end
      
end
