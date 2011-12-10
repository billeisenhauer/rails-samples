class AlterCurrencyFieldsWithPrecision < ActiveRecord::Migration
  
  def self.up
    change_column :inventory_assets, :unit_cost_amount,   :decimal, :precision => 10, :scale => 2, :default => 0.0
    change_column :inventory_assets, :engineering_amount, :decimal, :precision => 10, :scale => 2, :default => 0.0
    change_column :inventory_assets, :shipping_amount,    :decimal, :precision => 10, :scale => 2, :default => 0.0
    change_column :inventory_assets, :total_cost_amount,  :decimal, :precision => 10, :scale => 2, :default => 0.0
    change_column :inventory_assets, :total_sales_amount, :decimal, :precision => 10, :scale => 2, :default => 0.0
    change_column :inventory_assets, :additional_amount,  :decimal, :precision => 10, :scale => 2, :default => 0.0
    change_column :inventory_assets, :unit_sales_amount,  :decimal, :precision => 10, :scale => 2, :default => 0.0
  end

  def self.down
    change_column :inventory_assets, :unit_cost_amount,   :decimal, :default => 0.0
    change_column :inventory_assets, :engineering_amount, :decimal, :default => 0.0
    change_column :inventory_assets, :shipping_amount,    :decimal, :default => 0.0
    change_column :inventory_assets, :total_cost_amount,  :decimal, :default => 0.0
    change_column :inventory_assets, :total_sales_amount, :decimal, :default => 0.0
    change_column :inventory_assets, :additional_amount,  :decimal, :default => 0.0
    change_column :inventory_assets, :unit_sales_amount,  :decimal, :default => 0.0
  end

end
