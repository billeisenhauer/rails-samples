class AddMorePerformanceIndices < ActiveRecord::Migration
  
  def self.up
    add_index :assets, :type
    add_index :sites,  :ancestry
  end

  def self.down
    remove_index :assets, :type
    remove_index :sites,  :ancestry
  end
  
end
