require File.dirname(__FILE__) + '/../spec_helper'

describe UserSitesController, "#route_for" do
  
  it "should map { :controller => 'user_sites', :action => 'edit' } to /change-site" do
    route_for(:controller => "user_sites", :action => "edit").should == {:path => '/change-site', :method => :get}
  end
  
  it "should map { :controller => 'user_sites', :action => 'update' } to /user_sites" do
    route_for(:controller => "user_sites", :action => "update").should == {:path => '/user_sites', :method => :put}
  end

end

describe UserSitesController, "forbidden checks" do
  
  before(:each) do
    activate_authlogic
  end
  
  it "should not permit edit request" do
    get :edit
    response.should redirect_to(signin_path)
  end
  
  it "should not permit update request" do
    put :update, :user => { 'site_id' => '9999'}
    response.should redirect_to(signin_path)
  end
  
end

describe UserSitesController, "edit" do
  
  before(:each) do
    activate_authlogic
    @current_user = Factory.create(:champion_user)
    login
  end
  
  it "should show site form" do
    get :edit
    response.should render_template('edit')
  end
  
end

describe UserSitesController, "update" do
  
  before(:each) do
    activate_authlogic
    @current_user = Factory.create(:champion_user)
    login
  end
  
  it "should reject non-visible site" do
    @current_user.should_receive(:update_attributes!).with('site_id' => '9999').and_raise(ActiveRecord::RecordInvalid.new(@current_user))
    put :update, :user => { 'site_id' => '9999'}
    response.should render_template('edit')
  end
  
  it "should set site" do
    @current_user.should_receive(:update_attributes!).with('site_id' => '9999').and_return(@current_user)
    put :update, :user => { 'site_id' => '9999'}
    response.should redirect_to(root_path)
    flash[:notice].should == "Site has been changed."
  end
  
end
