class AddTagColumns < ActiveRecord::Migration
  
  def self.up
    rename_column :tags, :imei, :tag_number
    add_column :tags, :last_reported_at, :datetime
    add_column :tags, :last_location,    :string
    add_column :tags, :site_id,          :integer
    add_index  :tags, :site_id
  end

  def self.down
    rename_column :tags, :tag_number, :imei
    remove_column :tags, :last_reported_at
    remove_column :tags, :last_location
    remove_column :tags, :site_id
    remove_index  :tags, :site_id
  end
  
end
