require 'spec_helper'

describe NotificationCondition do
  
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    NotificationCondition.new(
      :field => 'vendor', 
      :operator => '==',
      :value => 'Geoforce'
    ).should be_valid
  end
  
  ### VALIDATIONS ###
  
  it "should be invalid with missing all attributes" do
    condition = NotificationCondition.new
    condition.should_not be_valid
    condition.should have(2).error_on(:field)
    condition.should have(2).error_on(:operator)
    condition.should have(1).error_on(:value)
  end
  
  it "should be invalid with field attribute only" do
    condition = NotificationCondition.new(:field => 'vendor')
    condition.should_not be_valid
    condition.should have(2).error_on(:operator)
    condition.should have(2).error_on(:value)
  end
  
  it "should be invalid with unknown field" do
    condition = NotificationCondition.new(:field => 'xxxx')
    condition.should_not be_valid
    condition.should have(1).error_on(:field)
    condition.should have(2).error_on(:operator)
    condition.should have(1).error_on(:value)
  end
  
  it "should be invalid with missing operator" do
    condition = NotificationCondition.new(
      :field => 'vendor',
      :value => 'xxxx'
    )
    condition.should_not be_valid
    condition.should have(2).error_on(:operator)
  end
  
  it "should be invalid with missing operator" do
    condition = NotificationCondition.new(
      :field => 'vendor',
      :operator => 'x',
      :value => 'xxxx'
    )
    condition.should_not be_valid
    condition.should have(1).error_on(:operator)
  end
  
  it "should be invalid with missing value" do
    condition = NotificationCondition.new(
      :field => 'total_amount',
      :operator => '=='
    )
    condition.should_not be_valid
    condition.should have(1).error_on(:value)
  end
  
  it "should be invalid with incompatible value" do
    condition = NotificationCondition.new(
      :field => 'total_sales_amount',
      :operator => '==',
      :value => 'xxxx'
    )
    condition.should_not be_valid
    condition.should have(1).error_on(:value)
  end
  
  ### FIELD HANDLING ###
  
  it "should handle datetime conditions" do
    nc = NotificationCondition.new(
      :field => 'last_seen_at', 
      :operator => '==',
      :value => '07/07/2010'
    )
    nc.should be_valid
    inventory = InventoryAsset.new(:last_seen_at => DateTime.parse('07/07/2010'))
    nc.satisfied_by?(inventory).should be_true
  end
  
  it "should handle invalid datetime conditions" do
    NotificationCondition.new(
      :field => 'last_seen_at', 
      :operator => '==',
      :value => 'xxxx'
    ).should_not be_valid
  end
  
  it "should handle date conditions" do
    nc = NotificationCondition.new(
      :field => 'installed_on', 
      :operator => '==',
      :value => '07/07/2010'
    )
    nc.should be_valid
    inventory = InventoryAsset.new(:installed_on => Date.parse('07/07/2010'))
    nc.satisfied_by?(inventory).should be_true
  end
  
  it "should handle boolean conditions" do
    nc = NotificationCondition.new(
      :field => 'tr_status', 
      :operator => '==',
      :value => 'true'
    )
    nc.should be_valid
    inventory = InventoryAsset.new(:tr_status => true)
    nc.satisfied_by?(inventory).should be_true
  end
  
  it "should handle integer conditions" do
    nc = NotificationCondition.new(
      :field => 'quantity_on_location', 
      :operator => '==',
      :value => '5'
    )
    nc.should be_valid
    inventory = InventoryAsset.new(:quantity_on_location => 5)
    nc.satisfied_by?(inventory).should be_true
  end
  
  it "should handle text conditions" do
    nc = NotificationCondition.new(
      :field => 'description', 
      :operator => '==',
      :value => 'This is a description.'
    )
    nc.should be_valid
    inventory = InventoryAsset.new(:description => 'This is a description.')
    nc.satisfied_by?(inventory).should be_true
  end
  
  it "should handle string conditions" do
    nc = NotificationCondition.new(
      :field => 'bill_and_hold', 
      :operator => '==',
      :value => 'xxx'
    )
    nc.should be_valid
    inventory = InventoryAsset.new(:bill_and_hold => 'xxx')
    nc.satisfied_by?(inventory).should be_true
  end
  
  it "should handle string conditions with not equal operator" do
    nc = NotificationCondition.new(
      :field => 'bill_and_hold', 
      :operator => '!=',
      :value => 'xxx'
    )
    nc.should be_valid
    inventory = InventoryAsset.new(:bill_and_hold => 'yyy')
    nc.satisfied_by?(inventory).should be_true
  end
  
end
