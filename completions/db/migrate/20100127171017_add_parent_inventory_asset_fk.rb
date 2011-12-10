class AddParentInventoryAssetFk < ActiveRecord::Migration
  
  def self.up
    add_column :inventory_assets, :parent_asset_id, :integer
  end

  def self.down
    remove_column :inventory_assets, :parent_asset_id
  end
  
end
