class CreateAssets < ActiveRecord::Migration
  
  def self.up
    create_table :assets do |t|
      t.string   :type, :state, :po_number, :vendor, :rfq_number, :client_name, 
                 :project, :so_number, :gr, :pe, :waybill, :who, :invoice_number, 
                 :quote, :for, :last_seen_location, :ocs_g, :field, :well, :code,
                 :category, :sub_category, :part_number, :serial_number,
                 :unit, :ticket_number
      t.integer  :quantity, :quantity_ordered, :quantity_received,
                 :quantity_on_hand, :measurement_unit, :total_amount, 
                 :unit_amount, :engineering_amount, :shipping_amount, 
                 :days_lead_time, :total_cost_amount, :total_sales_amount,
                 :cos, :site_id, :tag_id
      t.decimal  :latitude, :precision => 20, :scale => 16
      t.decimal  :longitude, :precision => 20, :scale => 16      
      t.text     :description, :notes, :custom
      t.date     :approved_on, :shipped_on, :received_on, :ordered_on,
                 :expected_delivery_on, :actual_delivery_on, :ticket_on,
                 :installed_on
      t.datetime :last_seen_at
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
  
end
