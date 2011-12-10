class AddChangeInventoryAssetColumns < ActiveRecord::Migration
  
  def self.up

    add_column :inventory_assets, :quantity_installed, :integer
    add_column :inventory_assets, :quantity_on_location, :integer
  end

  def self.down
    remove_column :inventory_assets, :quantity_installed
    remove_column :inventory_assets, :quantity_on_location
  end
  
end
