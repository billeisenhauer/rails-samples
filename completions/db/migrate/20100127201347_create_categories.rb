class CreateCategories < ActiveRecord::Migration

  def self.up
    create_table :categories do |t|
      t.integer :site_id
      t.string  :name
      t.string  :ancestry
      t.integer :ancestry_depth
      t.string  :ancestry_names
    end
    
    add_column    :inventory_assets, :category_id, :integer
    remove_column :inventory_assets, :category
    remove_column :inventory_assets, :sub_category
  end

  def self.down
    remove_column :inventory_assets, :category_id 
    add_column    :inventory_assets, :category, :string
    add_column    :inventory_assets, :sub_category, :string
    drop_table :categories
  end

end
