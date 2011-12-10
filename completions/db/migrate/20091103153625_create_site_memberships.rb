class CreateSiteMemberships < ActiveRecord::Migration
  
  def self.up
    create_table :site_memberships do |t|
      t.integer :user_id, :site_id
    end
    add_index :site_memberships, [:user_id, :site_id], :unique => true
    add_index :site_memberships, :user_id
    add_index :site_memberships, :site_id
    add_column :users, :site_id, :integer
  end

  def self.down
    remove_column :users, :site_id
    drop_table :site_memberships
  end
  
end
