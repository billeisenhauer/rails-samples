require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController, "#route_for" do

  it "should map { :controller => 'users', :action => 'index' } to /users" do
    route_for(:controller => "users", :action => "index").should == "/users"
  end
  
  it "should map { :controller => 'users', :action => 'new' } to /users/new" do
    route_for(:controller => "users", :action => "new").should == "/users/new"
  end
  
  it "should map { :controller => 'users', :action => 'show', :id => 'beisenhauer' } to /users/beisenhauer" do
    route_for(:controller => "users", :action => "show", :id => 'beisenhauer').should == "/users/beisenhauer"
  end
  
  it "should map { :controller => 'users', :action => 'edit', :id => 'beisenhauer' } to /users/beisenhauer/edit" do
    route_for(:controller => "users", :action => "edit", :id => 'beisenhauer').should == "/users/beisenhauer/edit"
  end
  
  it "should map { :controller => 'users', :action => 'update', :id => 'beisenhauer' } to /users/beisenhauer" do
    route_for(:controller => "users", :action => "update", :id => 'beisenhauer').should == {:path => '/users/beisenhauer', :method => :put}
  end
  
  it "should map { :controller => 'users', :action => 'destroy', :id => 'beisenhauer' } to /users/beisenhauer" do
    route_for(:controller => "users", :action => "destroy", :id => 'beisenhauer').should == {:path => '/users/beisenhauer', :method => :delete}
  end
  
  it "should map { :controller => 'users', :action => 'bulk' } to /users/bulk" do
    route_for(:controller => "users", :action => "bulk").should == {:path => '/users/bulk', :method => :put}
  end
  
end

describe UsersController, "authentication checks" do
  
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
  
  it "should not permit delete request" do
    delete :destroy, :id => '1'
    response.should redirect_to(signin_path)
  end
  
  it "should not permit bulk update request" do
    put :bulk
    response.should redirect_to(signin_path)
  end  
  
end

describe UsersController, "create user" do
  
  before(:each) do
    activate_authlogic
    @current_user = Factory.create(:administrator_user)
    login
  end
  
  # it "should sign in user" do
  #   user = mock('user')
  #   User.should_receive(:new).with('username' => 'beisenhauer').and_return(user)
  #   user.should_receive(:save!)
  #   post :create, :user => {'username' => 'beisenhauer'}
  #   #response.should redirect_to(users_path)
  #   flash[:notice].should == "Successfully created user."
  # end
  
end