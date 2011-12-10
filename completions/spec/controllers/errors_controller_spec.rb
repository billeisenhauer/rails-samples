require File.dirname(__FILE__) + '/../spec_helper'

describe ErrorsController, "#route_for" do

  it "should map { :controller => 'errors', :action => 'site_membership_required' } to /site_membership_required" do
    route_for(:controller => "errors", :action => "site_membership_required").should == "/site_membership_required"
  end
  
  it "should map { :controller => 'errors', :action => 'unauthorized' } to /unauthorized" do
    route_for(:controller => "errors", :action => "unauthorized").should == "/unauthorized"
  end
  
end