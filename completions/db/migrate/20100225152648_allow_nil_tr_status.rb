class AllowNilTrStatus < ActiveRecord::Migration
  
  def self.up
    change_column :inventory_assets, :tr_status, :boolean, :default => nil
  end

  def self.down
    change_column :inventory_assets, :tr_status, :boolean, :default => true
  end
  
end
