class User < ActiveRecord::Base
  
  NETWORK_USER_CLASS = Kernel.const_get(AppConfig.ldap_user_class)
  
  ### ASSOCIATIONS ###
  
  has_many   :site_memberships
  has_many   :sites, :through => :site_memberships, :order => 'ancestry_names ASC'
  belongs_to :site
  belongs_to :role
  
  ### CALLBACKS ###
  
  before_save :assign_site
  
  ### VALIDATIONS ###
  
  validates_presence_of :username
  validates_format_of   :username, :with => /[A-Za-z][A-Za-z0-9]*/
  # validates_format_of   :email,    :with => /[\w\.%\+\-]+@slb.com/, 
  #                       :allow_nil => true
  validate :ensure_member_of_site
  
  ### FINDERS / NAMED SCOPES ###
  
  named_scope :for_role, lambda { |role_name|
    { :include => [:role, :sites],
      :conditions => ['roles.name = ?', role_name] } 
  }
  named_scope :for_site, lambda { |filter_site|
    if filter_site
      { :include => [:role, :sites],
        :conditions => ['users.id in (?)', filter_site.members] } 
    else
      {}
    end
  }
  named_scope :sorted_by, lambda { |sort_options|
    field, direction = sort_options.split(' ')
    if field == 'role'
      { :include => [:role, :sites],
        :order => "lower(roles.name) #{direction}" }
    else  
      { :include => [:role, :sites],
        :order => "lower(users.#{field}) #{direction}" }    
    end
  }
  named_scope :unauthorized, {
    :include => [:role, :sites],
    :conditions => 'users.role_id IS NULL or users.site_id IS NULL'
  }
  
  def self.recipient_list_for(site)
    User.for_site(site).select { |u| u.identified? }
  end
   
  ### AUTHENTICATION ###

  acts_as_authentic do |c| 
    c.validate_password_field              = false
    c.disable_perishable_token_maintenance = true
    c.logged_in_timeout                    = AppConfig.session_timeout_period
  end
  
  def network_user
    @network_user ||= NETWORK_USER_CLASS.find(username)
  end
  
  # Tries to find a User first by looking into the database and then by
  # creating a User if there's a network entry for the given username
  def self.find_or_create_from_network(username)
    find(
      :first, 
      :conditions => ['username = ?', username], 
      :include => [:role, :site, :sites]
    ) || create_from_network_if_valid(username)
  end
  
  # Creates a User record in the database if there is an entry in the network
  # with the given username
  def self.create_from_network_if_valid(username)
    network_user = NETWORK_USER_CLASS.find(username)
    return nil unless network_user
    User.create(
      :username => username, 
      :email => network_user['mail'],
      :name => network_user['displayName']
    ) 
  end
  
  ### AUTHORIZATION ###
  
  def role_symbols    
    return [:uninvited] unless role
    [role.name.downcase.parameterize('_').to_sym]
  end
  
  def role_name
    role ? role.name : ''
  end
  
  def guest?
    role_name == 'Guest'
  end
  
  ### SITE MEMBERSHIPS ###
  
  def visible_sites
    sites.map(&:subtree).flatten.uniq
  end
  
  def can_change_sites?
    visible_sites.size > 1
  end
  
  ### SEARCHING / SORTING / FILTERING ###
  
  def self.filter(list_options={:sorted_by => 'username asc'})
    ar_proxy = User
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
  
  ###  MISCELLANEOUS ###
  
  def to_param
    username
  end
  
  def display_name
    name || email || 'Unamed'
  end
  
  def identified?
    !! (name || email)
  end
  
  protected
  
    # Authenticates the user against the network.
    def valid_network_credentials?(password_plaintext)
      !! NETWORK_USER_CLASS.authenticate(network_user, password_plaintext)
    end
    
    def ensure_member_of_site
      return unless site || site_id
      site = site || Site.find(site_id) rescue nil
      unless site
        self.errors.add(:site, 'does not exist')
        return
      end
      unless site.visible?(self)
        self.errors.add(:site, 'not a member of that site')
      end
    end
    
    def assign_site
      return if sites.empty?
      self.site ||= sites.first
    end
  
end
