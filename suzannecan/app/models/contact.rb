class Contact < ActiveRecord::Base
  
  EMAIL_NAME_REGEX  = '[\w\.%\+\-]+'.freeze
  DOMAIN_HEAD_REGEX = '(?:[A-Z0-9\-]+\.)+'.freeze
  DOMAIN_TLD_REGEX  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  EMAIL_REGEX       = /\A#{EMAIL_NAME_REGEX}@#{DOMAIN_HEAD_REGEX}#{DOMAIN_TLD_REGEX}\z/i
  
  ### ATTRIBUTES / ACCESSIBILITY ###
  
  attr_accessible :name, :email, :phone, :city, :message
  
  ### VALIDATIONS ###
  
  validates_presence_of :name
  validates_presence_of :email, :if => :no_phone_entered?
  validates_length_of   :email, :within => 6..100
  validates_format_of   :email, :with => EMAIL_REGEX
  validates_presence_of :phone, :if => :no_email_entered?
  validates_presence_of :city
  validates_presence_of :message
  
  protected
  
    def no_phone_entered?
      !(phone && phone.any?)
    end
    
    def no_email_entered?
      !(email && email.any?)
    end
  
end
