class CreateTagReaders < ActiveRecord::Migration
  
  def self.up
    create_table :tag_readers do |t|
      t.integer  :site_id
      t.string   :reader, :address
      t.decimal  :latitude, :precision => 20, :scale => 16
      t.decimal  :longitude, :precision => 20, :scale => 16
      t.datetime :last_reported_at
      t.timestamps
    end
  end

  def self.down
    drop_table :tag_readers
  end
  
end
