class CreateUsers < ActiveRecord::Migration
  
  def self.up
    create_table :users do |t|
      t.string    :username, :persistence_token
      t.integer   :login_count, :null => false, :default => 0
      t.timestamp :last_request_at, :last_login_at, :current_login_at
      t.string    :last_login_ip, :current_login_ip
      t.string    :time_zone, :null => false, :default => 'Central Time (US & Canada)'
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
  
end
