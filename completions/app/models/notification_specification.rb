class NotificationSpecification < ActiveRecord::Base
  
  ### ASSOCIATIONS ###
  
  belongs_to :site
  belongs_to :user
  has_many   :notification_conditions
  has_many   :notification_recipients
  has_many   :recipients, :through => :notification_recipients, :source => :user
  
  ### VALIDATIONS ###
  
  validates_presence_of :name
  validate              :ensure_recipients
  
  ### ATTRIBUTES ###
  
  attr_accessible :name, :site_id, :user_id,
                  :notification_recipients_attributes, 
                  :notification_conditions_attributes
  accepts_nested_attributes_for :notification_recipients, 
                                :allow_destroy => true
  accepts_nested_attributes_for :notification_conditions, 
                                :reject_if => lambda { |a| a.values.all?(&:blank?) }, 
                                :allow_destroy => true
  
  ### FINDERS / NAMED SCOPES ###
  
  named_scope :for_site, lambda { |filter_site|
    if filter_site
      { :conditions => [
          'notification_specifications.id in (?)', 
          filter_site.all_notification_specifications
        ] 
      } 
    else
      {}
    end
  }
  
  named_scope :sorted_by, lambda { |sort_options|
    field, direction = sort_options.split(' ')
    options = case field
      when 'site'
        { :order => "lower(sites.name) #{direction}" }
      when 'creator'
        { :order => "lower(users.name) #{direction}" }
      else
        { :order => "lower(notification_specifications.#{field}) #{direction}" }
    end
    options.merge(:include => [:site, :user, :notification_recipients])
  }
  
  ### SEARCHING / SORTING / FILTERING ###
  
  def self.filter(list_options={:sorted_by => 'name'})
    ar_proxy = NotificationSpecification
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
  
  ### RECIPIENT SUPPORT ###
  
  def self.recipients_for(inventory_asset)
    return [] unless inventory_asset && inventory_asset.is_a?(InventoryAsset)
    specs = NotificationSpecification.all.inject([]) do |arr, spec| 
      arr << spec if spec.satisfied_by?(inventory_asset)
      arr
    end
    # Get all recipients.
    all_recipients = specs.map(&:recipients).inject([]) { |list, r| list + r }.uniq
    # Combine into one string, convert to an array, de-dupe, combine back into
    # a string.
    all_recipients.map(&:email).compact.join(',')
  end
  
  def satisfied_by?(inventory_asset)
    notification_conditions.each do |condition|
      return false unless condition.satisfied_by?(inventory_asset)
    end
    true
  end
  
  ### MISCELLANEOUS ###
  
  def site_name
    site ? site.name : 'No site'
  end
  
  def creator
    user ? user.display_name : 'Unknown'
  end
  
  def recipients_list
    recipients.map(&:display_name).join(', ')
  end
      
  protected
  
    def ensure_recipients
      if notification_recipients.empty?
        errors.add_to_base("At least one recipient is required.")
      end
    end
    
end
