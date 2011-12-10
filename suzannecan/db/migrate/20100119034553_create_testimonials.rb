class CreateTestimonials < ActiveRecord::Migration
  def self.up
    create_table :testimonials do |t|
      t.column :quote,    :text,    :null => false    
      t.column :title,    :string,  :limit => 100
      t.column :byline,   :string,  :limit => 255, :null => false
      t.column :state,    :string,  :default => 'pending'  
      t.column :position, :integer, :default => 1000
      t.timestamps
    end
  end

  def self.down
    drop_table :testimonials
  end
end
