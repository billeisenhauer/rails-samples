class RemoveUnneededColumns < ActiveRecord::Migration
  
  def self.up
    remove_column :inventory_assets, :unit
    remove_column :inventory_assets, :approved_on
  end

  def self.down
    add_column    :inventory_assets, :unit, :string
    add_column    :inventory_assets, :approved_on, :date
  end
  
end
