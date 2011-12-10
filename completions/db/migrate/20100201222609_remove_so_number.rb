class RemoveSoNumber < ActiveRecord::Migration
  
  def self.up
    remove_column :inventory_assets, :so_number
  end

  def self.down
    add_column :inventory_assets, :so_number, :string
  end
  
end
