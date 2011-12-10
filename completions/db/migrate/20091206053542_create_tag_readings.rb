class CreateTagReadings < ActiveRecord::Migration
  
  def self.up
    create_table :tag_readings do |t|
      t.integer  :tag_id
      t.decimal  :latitude, :precision => 20, :scale => 16
      t.decimal  :longitude, :precision => 20, :scale => 16
      t.timestamps
    end
    
    add_index :tag_readings, :tag_id
  end

  def self.down
    drop_table :tag_readings
  end
  
end
