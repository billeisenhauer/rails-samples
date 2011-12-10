class ConvertToMoneyDecimalColumns < ActiveRecord::Migration
  
  def self.up
    change_column :inventory_assets, :total_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :inventory_assets, :unit_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :inventory_assets, :engineering_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :inventory_assets, :shipping_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :inventory_assets, :total_cost_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    change_column :inventory_assets, :total_sales_amount, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
    change_column :inventory_assets, :total_amount, :integer, :default => 0
    change_column :inventory_assets, :unit_amount, :integer, :default => 0
    change_column :inventory_assets, :engineering_amount, :integer, :default => 0
    change_column :inventory_assets, :shipping_amount, :integer, :default => 0
    change_column :inventory_assets, :total_cost_amount, :integer, :default => 0
    change_column :inventory_assets, :total_sales_amount, :integer, :default => 0
  end
  
end
