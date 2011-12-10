require 'spec_helper'

describe NotificationSpecification do

  before(:each) do
  end

  # it "should create a new instance given valid attributes" do
  #   NotificationSpecification.new(
  #     :name => 'Test Name', 
  #     :recipients => 'bill@slb.com,bill2@slb.com'
  #   ).should be_valid
  # end
  
  # it "should create a new instance given valid attributes and with a trailing comma" do
  #   NotificationSpecification.new(
  #     :name => 'Test Name', 
  #     :recipients => 'bill@slb.com,bill2@slb.com,   '
  #   ).should be_valid
  # end
  
  it "is not valid without a name" do
    spec = NotificationSpecification.new(:recipients => 'bill@slb.com,bill2@slb.com')
    spec.should_not be_valid
    spec.should have(1).error_on(:name)
  end
  
  # it "is not valid without recipients" do
  #   spec = NotificationSpecification.new(:name => 'Test Name')
  #   spec.should_not be_valid
  #   spec.should have(2).error_on(:recipients)
  # end
  
  # it "is not valid with invalid email address" do
  #   spec = NotificationSpecification.new(
  #     :name => 'Test Name', 
  #     :recipients => 'bill'
  #   )
  #   spec.should_not be_valid
  #   spec.should have(1).error_on(:recipients)
  # end
  
  # it "is not valid with non-SLB recipients" do
  #   spec = NotificationSpecification.new(
  #     :name => 'Test Name', 
  #     :recipients => 'bill@slbx.com,bill2@slb.com'
  #   )
  #   spec.should_not be_valid
  #   spec.should have(1).error_on(:recipients)
  # end
  
end
