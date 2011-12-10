class Site < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  ### BEHAVIORS ###
  
  acts_as_tree :cache_depth => true
  before_save  :update_descendants_with_new_ancestry_names
  
  ### ASSOCIATIONS ###
  
  has_many :site_memberships
  has_many :users, :through => :site_memberships
  has_many :tags
  has_many :tag_readers
  has_many :inventory_assets
  has_many :notification_specifications
  has_many :categories
  
  ### ATTRIBUTES ###
  
  attr_accessible :name, :parent_id
  
  ### VALIDATIONS ###
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  ### FINDERS / NAMED SCOPES ###
  
  named_scope :sorted_by, lambda { |sort_option|
    case sort_option.to_s
      when 'name'
        { :include => [:users],
          :order => 'lower(sites.name) ASC' }
      when 'ancestry_names'
        { :include => [:users],
          :order => "sites.ancestry_names" }
    end 
  }  
  named_scope :for_site, lambda { |filter_site|
    if filter_site
      { :include => [:users],
        :conditions => filter_site.subtree_conditions } 
    else
      {}
    end
  }
  
  ### SEARCHING / SORTING / FILTERING ###
  
  def self.filter(list_options={:sorted_by => 'ancestry_names'})
    ar_proxy = Site
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
  
  ### MEMBERSHIPS ###
  
  def all_users
    ancestor_users + users + descendant_users
  end
  memoize :all_users
  
  def members
    users + descendant_users
  end
  memoize :members
  
  def all_users_count
    all_users.size
  end
  
  def ancestor_users
    ancestors.map(&:users).flatten
  end
  memoize :ancestor_users
  
  def descendant_users
    descendants.map(&:users).flatten
  end
  memoize :descendant_users
  
  def member?(user)
    members.include?(user)
  end
  memoize :member?
  
  def visible?(user)
    all_users.include?(user)
  end
  memoize :visible?
  
  ### TAGS ###
  
  def tags_count
    tags.size
  end
  
  def all_tags
    tags + descendant_tags
  end
  memoize :all_tags
  
  def all_tags_count
    all_tags.size
  end
  
  def descendant_tags
    descendants.map(&:tags).flatten
  end
  memoize :descendant_tags
  
  ### TAG READERS ###
  
  def tag_readers_count
    tag_readers.size
  end
  
  def all_tag_readers
    tag_readers + descendant_tag_readers
  end
  memoize :all_tag_readers
  
  def all_tag_readers_count
    all_tag_readers.size
  end
  
  def descendant_tag_readers
    descendants.map(&:tag_readers).flatten
  end
  memoize :descendant_tag_readers
  
  ### NOTIFICATIONS ###
  
  def notification_specifications_count
    notification_specifications.size
  end
  
  def all_notification_specifications
    notification_specifications + descendant_notification_specifications
  end
  memoize :all_notification_specifications
  
  def all_notification_specifications_count
    all_notification_specifications.size
  end
  
  def descendant_notification_specifications
    descendants.map(&:notification_specifications).flatten
  end
  memoize :descendant_notification_specifications 
  
  ### CATEGORIES ###
  
  def categories_count
    categories.size
  end
  
  def all_categories
    categories + descendant_categories
  end
  memoize :all_categories
  
  def all_categories_count
    all_categories.size
  end
  
  def descendant_categories
    descendants.map(&:categories).flatten
  end
  memoize :descendant_categories
  
  ### INVENTORY ###
  
  def inventory_assets_count
    inventory_assets.size
  end
  
  def all_inventory_assets
    inventory_assets + descendant_inventory_assets
  end
  memoize :all_inventory_assets
  
  def all_inventory_assets_count
    all_inventory_assets.size
  end
  
  def descendant_inventory_assets
    descendants.map(&:inventory_assets).flatten
  end
  memoize :descendant_inventory_assets 
  
  ### MISCELLANEOUS ###
  
  def can_destroy?
    tags.empty? && users.empty? && categories.empty?
  end
  
  def allows_bulk_actions?
    can_destroy?
  end
  
  protected
  
    def update_descendants_with_new_ancestry_names
      if ancestry
        self.ancestry_names = get_ordered_sites.map(&:name).join(' > ')
      else
        self.ancestry_names = name
      end
    end
    
    def get_ordered_sites
      ids = ancestry.split('/')
      sites = Site.find(ids) rescue []
      ordered_sites = []
      if sites.any?
        ids.each { |id| ordered_sites << sites.detect { |site| site.id == id.to_i } }
      end
      ordered_sites << self
      ordered_sites
    end
    
    def before_destroy
      returning can_destroy? do |okay_to_destroy|
        errors.add_to_base "Cannot delete site with users or tags" unless okay_to_destroy
      end
    end
  
end
