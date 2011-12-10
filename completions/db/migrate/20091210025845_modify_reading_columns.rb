class ModifyReadingColumns < ActiveRecord::Migration
  
  def self.up
    remove_column :tag_readings, :latitude
    remove_column :tag_readings, :longitude
    add_column :tag_readings, :tag_reader_id, :integer
  end

  def self.down
    remove_column :tag_readings, :tag_reader_id
    add_column :tag_readings, :latitude,  :decimal, :precision => 20, :scale => 16
    add_column :tag_readings, :longitude, :decimal, :precision => 20, :scale => 16
  end
  
end
