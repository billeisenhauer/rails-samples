class Role < ActiveRecord::Base
  
  ### VALIDATIONS ###
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  ### ASSOCIATIONS ###
  
  has_many :users
  
  ### FINDERS / NAMED SCOPES ###
  
  def self.guest
    find_by_name('Guest')
  end

  def self.champion
    find_by_name('Champion')
  end

  def self.administrator
    find_by_name('Administrator')
  end
  
  def self.support_administrator
    find_by_name('Support Administrator')
  end
  
  def self.assignable_roles
    available_role_names = %w(Guest Champion Administrator)
    find(:all, :conditions => ['name in (?)', available_role_names], :order => 'id asc')
  end
  
end