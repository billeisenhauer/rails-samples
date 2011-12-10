class RenameAssetsTable < ActiveRecord::Migration
  
  def self.up
    rename_table :assets, :inventory_assets
    remove_column :inventory_assets, :type
  end

  def self.down
    rename_table :inventory_assets, :assets
    add_column :assets, :type, :string
  end
  
end
