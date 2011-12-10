class AdditionalInventoryAssetColumnChanges < ActiveRecord::Migration
  
  def self.up
    change_column :inventory_assets, :gr, :boolean
    rename_column :inventory_assets, :received_on, :gr_on
    rename_column :inventory_assets, :ticket_number, :fo
    rename_column :inventory_assets, :ticket_on, :fo_on
  end

  def self.down
    change_column :inventory_assets, :gr, :string
    rename_column :inventory_assets, :gr_on, :received_on
    rename_column :inventory_assets, :fo, :ticket_number
    rename_column :inventory_assets, :fo_on, :ticket_on
  end
  
end
