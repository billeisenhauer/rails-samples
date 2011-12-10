class CreateSites < ActiveRecord::Migration
  
  def self.up
    create_table :sites do |t|
      t.string  :name
      t.string  :ancestry
      t.integer :ancestry_depth
    end    
    
    root = Site.create!(:name => 'Schlumberger')
    ngc  = root.children.create(:name => 'NGC')
    completions = ngc.children.create(:name => 'Completions')
    completions.children.create(:name => 'RMC')
  end

  def self.down
    drop_table :sites
  end
  
end
