class FixUserRolesCardinality < ActiveRecord::Migration
  
  def self.up
    add_column :users, :role_id, :integer
    User.all.each do |user|
      user.update_attributes(:role => user.roles.first)
    end
    drop_table :roles_users
  end

  def self.down
    create_table :roles_users, :id => false do |t|
      t.integer :role_id, :user_id
    end
    add_index "roles_users", "role_id"
    add_index "roles_users", "user_id"
    remove_column :users, :role_id
  end
  
end
