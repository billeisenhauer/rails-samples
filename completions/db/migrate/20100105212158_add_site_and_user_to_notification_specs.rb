class AddSiteAndUserToNotificationSpecs < ActiveRecord::Migration
  
  def self.up
    add_column :notification_specifications, :site_id, :integer
    add_column :notification_specifications, :user_id, :integer
  end

  def self.down
    remove_column :notification_specifications, :site_id
    remove_column :notification_specifications, :user_id
  end
  
end
