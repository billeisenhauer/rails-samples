class CreateInventoryAssetSubscriptions < ActiveRecord::Migration
  
  def self.up
    create_table :inventory_asset_subscriptions do |t|
      t.integer :user_id, :inventory_asset_id
      t.timestamps
    end
    add_index :inventory_asset_subscriptions, :user_id
    add_index :inventory_asset_subscriptions, :inventory_asset_id
  end

  def self.down
    drop_table :inventory_asset_subscriptions
  end
  
end
