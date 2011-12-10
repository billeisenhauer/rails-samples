class AddAncestryNamesToSite < ActiveRecord::Migration
  
  def self.up
    add_column :sites, :ancestry_names, :string
  end

  def self.down
    remove_column :sites, :ancestry_names
  end
  
end
