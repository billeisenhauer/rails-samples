class AddAmountColumns < ActiveRecord::Migration

  def self.up
    add_column    :inventory_assets, :additional_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column    :inventory_assets, :unit_sales_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column    :inventory_assets, :tr_on, :date
    rename_column :inventory_assets, :unit_amount, :unit_cost_amount
    remove_column :inventory_assets, :quantity
    remove_column :inventory_assets, :quantity_on_hand
    remove_column :inventory_assets, :waybill
    remove_column :inventory_assets, :who
    remove_column :inventory_assets, :quote
    remove_column :inventory_assets, :for
    remove_column :inventory_assets, :code
    remove_column :inventory_assets, :invoice_number
    remove_column :inventory_assets, :total_amount
    remove_column :inventory_assets, :shipped_on
    remove_column :inventory_assets, :latitude
    remove_column :inventory_assets, :longitude
  end

  def self.down
    remove_column :inventory_assets, :additional_amount
    remove_column :inventory_assets, :unit_sales_amount
    remove_column :inventory_assets, :tr_on
    add_column    :inventory_assets, :total_amount, :decimal, :precision => 8, :scale => 2, :default => 0
    rename_column :inventory_assets, :unit_cost_amount, :unit_amount
    add_column    :inventory_assets, :quantity, :integer
    add_column    :inventory_assets, :quantity_on_hand, :integer
    add_column    :inventory_assets, :waybill, :string
    add_column    :inventory_assets, :who, :string  
    add_column    :inventory_assets, :quote, :string  
    add_column    :inventory_assets, :for, :string 
    add_column    :inventory_assets, :code, :string  
    add_column    :inventory_assets, :invoice_number, :string
    add_column    :inventory_assets, :shipped_on, :string
    add_column    :inventory_assets, :latitude, :decimal, :precision => 20, :scale => 16
    add_column    :inventory_assets, :longitude, :decimal, :precision => 20, :scale => 16
  end

end
