class SiteMembership < ActiveRecord::Base
  
  ### ASSOCIATIONS ###
  
  belongs_to :user
  belongs_to :site
  
  ### VALIDATIONS ###
  
  validates_presence_of   :user, :message => 'is required'
  validates_presence_of   :site, :message => 'is required'
  validates_uniqueness_of :user_id, :scope => :site_id,
                          :message => 'is already a member of the site'
  
end
