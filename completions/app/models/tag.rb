class Tag < ActiveRecord::Base
  
  ### CALLBACKS ###
  
  after_save :update_inventory_asset_location
  
  ### ASSOCIATIONS ###
  
  belongs_to :site
  has_one    :inventory_asset
  
  ### VALIDATIONS ###
  
  validates_presence_of   :tag_number
  validates_format_of     :tag_number, :with => /^(\d{1,3}\.){3}\d{1,3}$/
  validates_uniqueness_of :tag_number
  
  ### FINDERS / NAMED SCOPES ###
  
  named_scope :for_site, lambda { |filter_site|
    if filter_site
      { :conditions => ['tags.id in (?)', filter_site.all_tags] } 
    else
      {}
    end
  }
  named_scope :sorted_by, lambda { |sort_options|
    field, direction = sort_options.split(' ')
    options = case field
      when 'site'
        { :order => "lower(sites.name) #{direction}" }
      when 'inventory_asset'
        { :order => "lower(inventory_assets.po_number) #{direction}" }
      else
        { :order => "lower(tags.#{field}) #{direction}" }
    end
    options.merge(:include => [:site, :inventory_asset])
  }
  named_scope :assigned,
              :select => "tags.*",
              :joins => "inner join inventory_assets as ia ON tags.id = ia.tag_id"
  named_scope :unassigned,
              :select => "tags.*",
              :conditions => 'tags.id not in (select tags.id from tags inner join inventory_assets as ia ON tags.id = ia.tag_id)'  
  
  ### SEARCHING / SORTING / FILTERING ###
  
  def self.filter(list_options={:sorted_by => 'tag_number'})
    ar_proxy = Tag
    if list_options.is_a?(Hash)
      list_options.each do |key, value|
        next unless list_option_names.include?(key) 
        next if value.blank? 
        ar_proxy = ar_proxy.send(key, value)
      end
    end
    ar_proxy
  end

  def self.list_option_names
    self.scopes.map{|s| s.first} + [:search]
  end
  
  def self.search(query)
    string_columns = []
    columns.each do |column|
      string_columns << column.name if column.type == :string
    end
    method_name = string_columns.join('_or_') + '_like'
    send(method_name, query)
  end
  
  ### MISCELLANEOUS ###
  
  def site_name
    site ? site.name : 'No site'
  end
  
  def inventory_asset_name
    inventory_asset ? inventory_asset.po_number : 'Unassigned'
  end
  
  def unseen_days_count
    (DateTime.now.to_date - last_reported_at.to_date).to_i
  end
  
  def last_location
    read_attribute(:last_location) || 'Not Reported'
  end
  
  protected
  
    def update_inventory_asset_location
      return unless inventory_asset
      inventory_asset.last_seen_location = read_attribute(:last_location)
      inventory_asset.last_seen_at       = last_reported_at
      inventory_asset.save(false)
    end
  
end
