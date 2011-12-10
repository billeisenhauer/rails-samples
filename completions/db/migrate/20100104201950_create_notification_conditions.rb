class CreateNotificationConditions < ActiveRecord::Migration
  
  def self.up
    create_table :notification_conditions do |t|
      t.integer :notification_specification_id 
      t.string  :field, :value, :field_type, :operator
    end
  end

  def self.down
    drop_table :notification_conditions
  end
  
end
