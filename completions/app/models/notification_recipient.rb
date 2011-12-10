class NotificationRecipient < ActiveRecord::Base
  
  ### ASSOCIATIONS ###
  
  belongs_to :user
  belongs_to :notification_specification
  
  ### VALIDATIONS ###
  
  validates_presence_of   :user, :message => 'is required'
  validates_uniqueness_of :user_id, :scope => :notification_specification_id,
                          :message => 'is already receiving this notification'
  
end
