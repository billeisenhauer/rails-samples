require File.dirname(__FILE__) + '/../spec_helper'

describe UserSessionsController, "#route_for" do

  it "should map { :controller => 'user_sessions', :action => 'new' } to /signin" do
    route_for(:controller => "user_sessions", :action => "new").should == "/signin"
  end

  it "should map { :controller => 'user_sessions', :action => 'destroy'} to /signout" do
    route_for(:controller => "user_sessions", :action => "destroy").should == {:path => '/signout', :method => :delete}
  end
  
end


describe UserSessionsController, "authentication checks" do
  
  before(:each) do
    activate_authlogic
  end
  
  it "should not permit destroy request" do
    delete :destroy
    response.should redirect_to(signin_path)
  end
  
end

describe UserSessionsController, "sign in" do
  
  before(:each) do
    activate_authlogic
  end
  
  it "should show signin page" do
    get :new
    response.should render_template('new')
  end
  
  it "should sign in user" do
    UserSessionsController.any_instance.stubs(:current_user).returns(nil)
    user_session_mock = user_session
    UserSession.should_receive(:new).
      with('username' => 'beisenhauer', 'password' => 'password').
      and_return(user_session_mock)
    user_session_mock.should_receive(:save).and_return(true)
    post :create, :user_session => {'username' => 'beisenhauer', 'password' => 'password'}
    response.should redirect_to(root_path)
    flash[:notice].should == "Sign in successful!"
  end  
  
  it "should reject sign in" do
    UserSessionsController.any_instance.stubs(:current_user).returns(nil)
    user_session_mock = user_session
    UserSession.should_receive(:new).
      with('username' => 'beisenhauer', 'password' => 'password').
      and_return(user_session_mock)
    user_session_mock.should_receive(:save).and_return(false)
    post :create, :user_session => {'username' => 'beisenhauer', 'password' => 'password'}
    response.should render_template('new')
    flash[:error].should  == "Couldn't sign you in as 'beisenhauer'"
  end
  
end

describe UserSessionsController, "sign out" do
  
  before(:each) do
    activate_authlogic
    @current_user = Factory.create(:champion_user)
    login
  end
  
  it "should not permit destroy request" do
    @current_user_session.should_receive(:destroy)
    delete :destroy
    response.should redirect_to(signin_path)
    flash[:notice].should == "Sign out successful!"
  end
  
end