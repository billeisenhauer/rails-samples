class AddUserRelationshipToAssetForPe < ActiveRecord::Migration
  
  def self.up
    add_column    :inventory_assets, :pe_id, :integer
    remove_column :inventory_assets, :pe
  end

  def self.down
    remove_column :inventory_assets, :pe_id
    add_column    :inventory_assets, :pe, :string
  end
  
end
