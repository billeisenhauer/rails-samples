class CreateImports < ActiveRecord::Migration
  
  def self.up
    create_table :imports do |t|
      t.string   :csv_file_name, :csv_content_type
      t.integer  :csv_file_size
      t.datetime :csv_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :imports
  end
  
end
