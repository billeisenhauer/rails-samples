class RemoveInventoryAssetSubscription < ActiveRecord::Migration
  
  def self.up
    add_column :inventory_assets, :recipients, :string
    drop_table :inventory_asset_subscriptions
  end

  def self.down
    create_table :inventory_asset_subscriptions do |t|
      t.integer :user_id, :inventory_asset_id
      t.timestamps
    end
    add_index :inventory_asset_subscriptions, :user_id
    add_index :inventory_asset_subscriptions, :inventory_asset_id
    remove_column :inventory_assets, :recipients
  end
  
end
