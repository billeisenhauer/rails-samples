require File.dirname(__FILE__) + '/../spec_helper'

describe Role do
  
  ### VALIDATIONS ###
  
  it "is valid with valid attributes" do
    Role.new(Factory.attributes_for(:role)).should be_valid
  end
  
  it "is not valid without a name" do
    role = Role.new(:name => nil)
    role.should_not be_valid
    role.should have(1).error_on(:name)
  end
  
  it "is not valid with a duplicate name" do
    admin = Factory.create(:administrator_role)
    role = Role.new(:name => admin.name)
    role.should_not be_valid
    role.should have(1).error_on(:name)
  end
  
  ### FINDERS ###
  
  it "returns guest" do
    guest = Factory.create(:guest_role)
    Role.guest.should eql(guest)
  end
  
  it "returns champion" do
    champion = Factory.create(:champion_role)
    Role.champion.should eql(champion)
  end
  
  it "returns administrator" do
    administrator = Factory.create(:administrator_role)
    Role.administrator.should eql(administrator)
  end
  
  it "returns support administrator" do
    support_administrator = Factory.create(:support_administrator_role)
    Role.support_administrator.should eql(support_administrator)
  end
  
  it "returns assignable roles" do
    guest = Factory.create(:guest_role)
    champion = Factory.create(:champion_role)
    administrator = Factory.create(:administrator_role)
    support_administrator = Factory.create(:support_administrator_role)
    Role.assignable_roles.should eql([guest, champion, administrator])
  end
  
  
  
end