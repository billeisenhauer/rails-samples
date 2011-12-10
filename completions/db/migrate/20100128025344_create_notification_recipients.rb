class CreateNotificationRecipients < ActiveRecord::Migration
  
  def self.up
    remove_column :notification_specifications, :recipients
    create_table :notification_recipients do |t|
      t.integer :notification_specification_id, :user_id
    end
    add_index :notification_recipients, [:user_id, :notification_specification_id], :unique => true, :name => 'nr_user_id_ns_id'
    add_index :notification_recipients, :user_id
    add_index :notification_recipients, :notification_specification_id
  end

  def self.down
    add_column :notification_specifications, :recipients, :string
    drop_table :notification_recipients
  end
  
end
