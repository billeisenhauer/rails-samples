class AddAdditionalColumns < ActiveRecord::Migration
  
  def self.up
    add_column :inventory_assets, :bill_and_hold, :string
    add_column :inventory_assets, :delivery_on, :date
    add_column :inventory_assets, :tr_assignment_id, :integer
    add_column :inventory_assets, :tr_status, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :inventory_assets, :bill_and_hold
    remove_column :inventory_assets, :delivery_on
    remove_column :inventory_assets, :tr_assignment_id
    remove_column :inventory_assets, :tr_status
  end
  
end
