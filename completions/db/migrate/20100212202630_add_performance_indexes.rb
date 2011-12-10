class AddPerformanceIndexes < ActiveRecord::Migration
  
  def self.up  
    add_index :inventory_assets, :last_seen_location
    add_index :inventory_assets, :ocs_g
    add_index :inventory_assets, :field
    add_index :inventory_assets, :well
    add_index :inventory_assets, :part_number
    add_index :inventory_assets, :serial_number
    add_index :inventory_assets, :fo
    add_index :categories, :site_id
    add_index :site_statistics, :site_id
  end

  def self.down
    remove_index :inventory_assets, :last_seen_location
    remove_index :inventory_assets, :ocs_g
    remove_index :inventory_assets, :field
    remove_index :inventory_assets, :well
    remove_index :inventory_assets, :part_number
    remove_index :inventory_assets, :serial_number
    remove_index :inventory_assets, :fo
    remove_index :categories, :site_id
    remove_index :site_statistics, :site_id
  end
  
end
