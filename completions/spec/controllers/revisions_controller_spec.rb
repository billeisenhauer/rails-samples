require 'spec_helper'

describe RevisionsController, "#route_for" do

  it "should map { :controller => 'revisions', :action => 'index', :inventory_asset_id => '1' } to /inventory_assets/1/revisions" do
    route_for(:controller => "revisions", :action => "index", :inventory_asset_id => '1').should == "/inventory_assets/1/revisions"
  end
  
end

describe RevisionsController, "authentication checks" do
  
  before(:each) do
    activate_authlogic
  end
  
  it "should not permit index request" do
    get :index, :inventory_asset_id => '1'
    response.should redirect_to(signin_path)
  end
  
end