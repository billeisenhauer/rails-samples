require 'spec_helper'

describe ProfilesController, "#route_for" do
  
  it "should map { :controller => 'profiles', :action => 'edit' } to /profile/edit" do
    route_for(:controller => "profiles", :action => "edit").should == {:path => '/profile/edit', :method => :get}
  end
  
  it "should map { :controller => 'profile', :action => 'update' } to /profile" do
    route_for(:controller => "profiles", :action => "update").should == {:path => '/profile', :method => :put}
  end

end

describe ProfilesController, "forbidden checks" do
  
  before(:each) do
    activate_authlogic
  end
  
  it "should not permit edit profile request" do
    get :edit
    response.should redirect_to(signin_path)
  end
  
  it "should not permit update profile request" do
    put :update, :user => { 'username' => 'blah'}
    response.should redirect_to(signin_path)
  end
  
end

describe ProfilesController, "edit" do
  
  before(:each) do
    activate_authlogic
    @current_user = Factory.create(:champion_user)
    login
  end
  
  it "should show profile form" do
    get :edit
    response.should render_template('edit')
  end
  
end

describe ProfilesController, "update" do
  
  before(:each) do
    activate_authlogic
    @current_user = Factory.create(:champion_user)
    login
  end
  
  it "should reject profile update" do
    @current_user.should_receive(:update_attributes!).with('username' => 'blah').and_raise(ActiveRecord::RecordInvalid.new(@current_user))
    put :update, :user => { 'username' => 'blah'}
    response.should render_template('edit')
  end
  
  it "should update profile" do
    @current_user.should_receive(:update_attributes!).with('username' => 'blah').and_return(@current_user)
    put :update, :user => { 'username' => 'blah'}
    response.should redirect_to(edit_profile_path)
    flash[:notice].should == "Successfully updated profile."
  end
  
end