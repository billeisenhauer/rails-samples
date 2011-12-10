class CreateSiteStatistics < ActiveRecord::Migration
  
  def self.up
    create_table :site_statistics do |t|
      t.date    :collected_on
      t.column  :site_id,         :integer, :null => false 
      t.column  :active_assets,   :integer, :default => 0, :null => false
      t.column  :archived_assets, :integer, :default => 0, :null => false
      t.column  :tagged_assets,   :integer, :default => 0, :null => false
    end
  end

  def self.down
    drop_table :site_statistics
  end
  
end
