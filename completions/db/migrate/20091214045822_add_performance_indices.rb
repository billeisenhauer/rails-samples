class AddPerformanceIndices < ActiveRecord::Migration
  
  def self.up
    add_index :tags, :tag_number
    add_index :tags, :last_location
    add_index :tags, :last_reported_at
    add_index :tag_readers, :site_id
    add_index :tag_readers, :reader
    add_index :users, :site_id
    add_index :users, :role_id
    add_index :assets, :state
    add_index :assets, :approved_on
    add_index :assets, :installed_on
    add_index :assets, :po_number
    add_index :assets, :rfq_number
    add_index :assets, :vendor
    add_index :assets, :client_name
    add_index :assets, :project
    add_index :assets, :so_number
    add_index :assets, :pe
    add_index :assets, :site_id
    add_index :assets, :tag_id
  end

  def self.down
    remove_index :tags, :tag_number
    remove_index :tags, :last_location
    remove_index :tags, :last_reported_at
    remove_index :tag_readers, :site_id
    remove_index :tag_readers, :reader
    remove_index :users, :site_id
    remove_index :users, :role_id
    remove_index :assets, :state
    remove_index :assets, :approved_on
    remove_index :assets, :installed_on
    remove_index :assets, :po_number
    remove_index :assets, :rfq_number
    remove_index :assets, :vendor
    remove_index :assets, :client_name
    remove_index :assets, :project
    remove_index :assets, :so_number
    remove_index :assets, :pe
    remove_index :assets, :site_id
    remove_index :assets, :tag_id
  end
  
end
