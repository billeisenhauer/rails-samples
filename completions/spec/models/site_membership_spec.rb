require File.dirname(__FILE__) + '/../spec_helper'

describe SiteMembership do
  
  before(:each) do
    @site = Factory.create(:site)
    @user = Factory.create(:user)
  end
  
  it "is valid with valid attributes" do
    SiteMembership.new(:user => @user, :site => @site).should be_valid
  end
  
  it "is not valid without a user" do
    site_membership = SiteMembership.new(:user => nil, :site => @site)
    site_membership.should_not be_valid
    site_membership.should have(1).error_on(:user)
  end
  
  it "is not valid without a site" do
    site_membership = SiteMembership.new(:user => @user, :site => nil)
    site_membership.should_not be_valid
    site_membership.should have(1).error_on(:site)
  end
  
  it "is not valid with duplicate member" do
    SiteMembership.create(:user => @user, :site => @site)
    site_membership = SiteMembership.new(:user => @user, :site => @site)
    site_membership.should_not be_valid
    site_membership.should have(1).error_on(:user_id)
  end

end