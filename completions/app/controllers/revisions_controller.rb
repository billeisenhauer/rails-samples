class RevisionsController < ApplicationController
  
  before_filter :require_user
  before_filter :load_inventory_asset
  filter_access_to :all, :attribute_check => false
  
  protected
  
    def load_inventory_asset
      @asset = InventoryAsset.find(params[:inventory_asset_id])
    end
  
end
