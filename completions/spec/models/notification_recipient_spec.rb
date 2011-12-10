require 'spec_helper'

describe NotificationRecipient do
  
  before(:each) do
    @user = Factory.create(:user)
    @valid_attributes = {
      :user => @user
    }
  end

  it "should create a new instance given valid attributes" do
    NotificationRecipient.create!(@valid_attributes)
  end
  
  it "should not create a new instance with duplicate user" do
    NotificationRecipient.create!(@valid_attributes)
    recipient = NotificationRecipient.new(:user => @user)
    recipient.should_not be_valid
    recipient.should have(1).error_on(:user_id)
  end
  
end
