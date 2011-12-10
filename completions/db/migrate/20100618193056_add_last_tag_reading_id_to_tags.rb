class AddLastTagReadingIdToTags < ActiveRecord::Migration
  
  def self.up
    add_column :tags, :last_tag_reading_id, :integer
    
    TagReading.latest.each do |tr|
      tr.tag.update_attributes(:last_tag_reading_id => tr.id)
    end
  end

  def self.down
    remove_column :tags, :last_tag_reading_id
  end
  
end
