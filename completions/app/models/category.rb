class Category < ActiveRecord::Base
  
  ### BEHAVIORS ###
  
  acts_as_tree :cache_depth => true
  before_save  :update_descendants_with_new_ancestry_names
  
  ### ASSOCIATIONS ###
  
  belongs_to :site
  has_many   :inventory_assets

  ### ATTRIBUTES ###
  
  attr_accessible :name, :parent_id, :site_id

  ### VALIDATIONS ###
  
  validates_presence_of   :site
  validates_presence_of   :name
  validates_uniqueness_of :name, :scope => [:site_id]
  
  ### FINDERS / NAMED SCOPES ###
  
  named_scope :for_site, lambda { |filter_site|
    if filter_site
      { :conditions => ['categories.id in (?)', filter_site.all_categories] } 
    else
      {}
    end
  }
  
  named_scope :sorted_by, lambda { |sort_options|
    field, direction = sort_options.split(' ')
    options = case field
      when 'site'
        { :order => "lower(sites.name) #{direction}" }
      else
        { :order => "lower(categories.#{field}) #{direction}" }
    end
    options.merge(:include => [:site])
  }
  
  ### SEARCHING / SORTING / FILTERING ###
  
  def self.filter(list_options={:sorted_by => 'ancestry_names asc'})
    ar_proxy = Category
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
  
  def can_destroy?
    inventory_assets.empty?
  end
  
  def allows_bulk_actions?
    can_destroy?
  end
  
  protected
  
    def update_descendants_with_new_ancestry_names
      if ancestry
        self.ancestry_names = get_ordered_categories.map(&:name).join(' > ')
      else
        self.ancestry_names = name
      end
    end
    
    def get_ordered_categories
      ids = ancestry.split('/')
      categories = Category.find(ids) rescue []
      ordered_categories = []
      if categories.any?
        ids.each { |id| ordered_categories << categories.detect { |category| category.id == id.to_i } }
      end
      ordered_categories << self
      ordered_categories
    end
      
end
