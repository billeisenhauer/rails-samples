class Testimonial < ActiveRecord::Base

  ### ATTRIBUTES / ACCESSIBILITY ###
  
  attr_accessible :quote, :title, :byline
  
  ### VALIDATIONS ###
  
  validates_presence_of :quote
  validates_length_of :title, :within => 0..255, :allow_blank => true
  validates_length_of :byline, :within => 1..255 
  
  ### FINDERS / SCOPES ###

  named_scope :pending, 
              :conditions => "state = 'pending'"  
  named_scope :approved, 
              :conditions => "state = 'approved'"
  named_scope :denied, 
              :conditions => "state = 'denied'"              
  named_scope :ordered, :order => 'position ASC'  
  
  def self.random_approved
    results = approved.ordered.all
    results.any? ? results[rand(results.size)] : nil
  end

end
