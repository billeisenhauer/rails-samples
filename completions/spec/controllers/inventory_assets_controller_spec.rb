require 'spec_helper'

describe InventoryAssetsController, "#route_for" do

  it "should map { :controller => 'inventory_assets', :action => 'index' } to /inventory_assets" do
    route_for(:controller => "inventory_assets", :action => "index").should == "/inventory_assets"
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'new' } to /inventory_assets/new" do
    route_for(:controller => "inventory_assets", :action => "new").should == "/inventory_assets/new"
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'show', :id => '1' } to /inventory_assets/1" do
    route_for(:controller => "inventory_assets", :action => "show", :id => '1').should == "/inventory_assets/1"
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'edit', :id => '1' } to /inventory_assets/1/edit" do
    route_for(:controller => "inventory_assets", :action => "edit", :id => '1').should == "/inventory_assets/1/edit"
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'update', :id => '1' } to /inventory_assets/1" do
    route_for(:controller => "inventory_assets", :action => "update", :id => '1').should == {:path => '/inventory_assets/1', :method => :put}
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'destroy', :id => '1' } to /inventory_assets/1" do
    route_for(:controller => "inventory_assets", :action => "destroy", :id => '1').should == {:path => '/inventory_assets/1', :method => :delete}
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'new_split', :id => '1' } to /inventory_assets/1/new_split" do
    route_for(:controller => "inventory_assets", :action => "new_split", :id => '1').should == {:path => '/inventory_assets/1/new_split'}
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'create_split', :id => '1' } to /inventory_assets/1/create_split" do
    route_for(:controller => "inventory_assets", :action => "create_split", :id => '1').should == {:path => '/inventory_assets/1/create_split', :method => :post}
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'sample_import' } to /inventory_assets/sample_import" do
    route_for(:controller => "inventory_assets", :action => "sample_import").should == "/inventory_assets/sample_import"
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'new_import' } to /inventory_assets/new_import" do
    route_for(:controller => "inventory_assets", :action => "new_import").should == "/inventory_assets/new_import"
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'import' } to /inventory_assets/import" do
    route_for(:controller => "inventory_assets", :action => "import").should == {:path => '/inventory_assets/import', :method => :put}
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'export' } to /inventory_assets/export" do
    route_for(:controller => "inventory_assets", :action => "export").should == "/inventory_assets/export"
  end
  
  it "should map { :controller => 'inventory_assets', :action => 'per_page' } to /inventory_assets/per_page" do
    route_for(:controller => "inventory_assets", :action => "per_page").should == {:path => '/inventory_assets/per_page', :method => :put}
  end
  
end

describe InventoryAssetsController, "authentication checks" do
  
  before(:each) do
    activate_authlogic
  end
  
  it "should not permit index request" do
    get :index
    response.should redirect_to(signin_path)
  end
  
  it "should not permit show request" do
    get :show, :id => '1'
    response.should redirect_to(signin_path)
  end
  
  it "should not permit edit request" do
    get :edit, :id => '1'
    response.should redirect_to(signin_path)
  end
  
  it "should not permit update request" do
    put :update, :id => '1'
    response.should redirect_to(signin_path)
  end
  
  it "should not permit new request" do
    get :new
    response.should redirect_to(signin_path)
  end
  
  it "should not permit create request" do
    post :create
    response.should redirect_to(signin_path)
  end
  
  it "should not permit sample import request" do
    get :sample_import
    response.should redirect_to(signin_path)
  end
  
  it "should not permit new import request" do
    get :new_import
    response.should redirect_to(signin_path)
  end
  
  it "should not permit import request" do
    put :import
    response.should redirect_to(signin_path)
  end
  
  it "should not permit sample per_page request" do
    put :per_page
    response.should redirect_to(signin_path)
  end
  
  it "should not permit delete request" do
    delete :destroy, :id => '1'
    response.should redirect_to(signin_path)
  end
  
  it "should not permit new_split request" do
    get :new_split, :id => '1'
    response.should redirect_to(signin_path)
  end
  
  it "should not permit create_split request" do
    post :create_split, :id => '1'
    response.should redirect_to(signin_path)
  end  
  
  it "should not permit update bulk request" do
    put :bulk
    response.should redirect_to(signin_path)
  end  
  
end
