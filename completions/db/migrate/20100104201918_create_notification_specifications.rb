class CreateNotificationSpecifications < ActiveRecord::Migration
  def self.up
    create_table :notification_specifications do |t|
      t.string :name, :recipients
      t.timestamps
    end
  end

  def self.down
    drop_table :notification_specifications
  end
end
