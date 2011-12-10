require 'spec_helper'

describe NotificationsController, "#route_for" do

  it "should map { :controller => 'notifications', :action => 'index' } to /notifications" do
    route_for(:controller => "notifications", :action => "index").should == "/notifications"
  end
  
  it "should map { :controller => 'notifications', :action => 'new' } to /notifications/new" do
    route_for(:controller => "notifications", :action => "new").should == "/notifications/new"
  end
  
  it "should map { :controller => 'notifications', :action => 'show', :id => '1' } to /notifications/1" do
    route_for(:controller => "notifications", :action => "show", :id => '1').should == "/notifications/1"
  end
  
  it "should map { :controller => 'notifications', :action => 'edit', :id => '1' } to /notifications/1/edit" do
    route_for(:controller => "notifications", :action => "edit", :id => '1').should == "/notifications/1/edit"
  end
  
  it "should map { :controller => 'notifications', :action => 'update', :id => '1' } to /notifications/1" do
    route_for(:controller => "notifications", :action => "update", :id => '1').should == {:path => '/notifications/1', :method => :put}
  end
  
  it "should map { :controller => 'notifications', :action => 'destroy', :id => '1' } to /notifications/1" do
    route_for(:controller => "notifications", :action => "destroy", :id => '1').should == {:path => '/notifications/1', :method => :delete}
  end
  
end

describe NotificationsController, "authentication checks" do
  
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
  
  it "should not permit update bulk request" do
    put :bulk
    response.should redirect_to(signin_path)
  end  
  
end

describe "privileged actions" do 
  
  before(:each) do
    @current_user = Factory.create(:administrator_user)
    @site = Factory.create(:site)
    SiteMembership.create(:user => @current_user, :site => @site)
    @recipient = NotificationRecipient.new(:user => @user)
    @notification_specification = NotificationSpecification.new(:site_id => @site.id, :user_id => @current_user.id, :name => 'name')
    @notification_specification.notification_recipients << @recipient
    @notification_specification.save
    activate_authlogic
    login
  end
  
  describe NotificationsController, 'bulk, index, and search' do
    
    it "should show index" do
      get :index
      response.should render_template('index')
    end
    
    it "should apply bulk site change" do
      NotificationSpecification.should_receive(:find).with(['1', '2', '3']).and_return([@notification_specification])
      @notification_specification.should_receive(:update_attributes).with(:site_id => @site.id)
      put :bulk, :spec_ids => ["1", "2", "3"], :bulk_site => @site.id, :bulk_site_change => "Apply"
      response.should redirect_to(notifications_path)
      flash[:notice].should == "Successfully assigned 1 notifications to #{@site.name}."
    end
    
    it "should not apply bulk site change if site not found" do
      NotificationSpecification.should_receive(:find).with(['1', '2', '3']).and_return([@notification_specification])
      Site.should_receive(:find).with('99999').and_raise(ActiveRecord::RecordNotFound)
      put :bulk, :spec_ids => ["1", "2", "3"], :bulk_site => '99999', :bulk_site_change => "Apply"
      response.should redirect_to(notifications_path)
      flash[:notice].should == "Don't know that site; nothing has been done."
    end
    
    it "should apply bulk deletes " do
      NotificationSpecification.should_receive(:find).with(['1', '2', '3']).and_return([@notification_specification])
      @notification_specification.should_receive(:destroy)
      put :bulk, :spec_ids => ["1", "2", "3"], :bulk_action => 'delete', :bulk_action_change => "Apply"
      response.should redirect_to(notifications_path)
      flash[:notice].should == 'Successfully deleted 1 notifications.'
    end
    
    it "should not apply bulk deletes if no bulk action was passed" do
      NotificationSpecification.should_receive(:find).with(['1', '2', '3']).and_return([@notification_specification])
      put :bulk, :spec_ids => ["1", "2", "3"], :bulk_action => nil, :bulk_action_change => "Apply"
      response.should redirect_to(notifications_path)
      flash[:error].should == "No action was selected; nothing has been done."
    end
    
    it "should not apply bulk deletes if no notifications passed" do
      put :bulk, :spec_ids => nil, :bulk_action_change => "Apply"
      response.should redirect_to(notifications_path)
      flash[:error].should == "No notifications were selected; nothing has been done."
    end    
    
  end
  
  describe NotificationsController, "creation" do
  
    it "should show new notification_specification form" do
      get :new
      response.should render_template('new')
    end
    
    it "should create new notification_specification" do
      new_notification_specification = NotificationSpecification.new
      NotificationSpecification.should_receive(:new).with('name' => 'Newest', 'site' => @site).
        and_return(new_notification_specification)
      new_notification_specification.should_receive(:save!)
      post :create, :notification_specification => {:name => 'Newest', :site => @site}
      flash[:notice].should == "Successfully created notification."
      response.should redirect_to(notifications_path)
    end
  
    it "should reject invalid new notification_specification" do
      new_notification_specification = NotificationSpecification.new
      NotificationSpecification.should_receive(:new).and_return(new_notification_specification)
      new_notification_specification.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(new_notification_specification))
      post :create
      response.should render_template('new')
    end
  
  end

  describe NotificationsController, "show, edit, update, and destroy" do
  
    before(:each) do
      NotificationSpecification.should_receive(:find).with('1').and_return(@notification_specification)
    end
    
    it "should show notification_specification form" do
      get :show, :id => '1'
      response.should render_template('show')
    end
    
    it "should show notification_specification form" do
      get :edit, :id => '1'
      response.should render_template('edit')
    end

    it "should update existing notification_specification" do
      @notification_specification.should_receive(:update_attributes!).with('name' => 'new name')
      put :update, :id => '1', :notification_specification => { 'name' => 'new name'}
      response.should redirect_to(notifications_path)
      flash[:notice].should == "Successfully updated notification."
    end
    
    it "should not update existing notification_specification" do
      @notification_specification.should_receive(:update_attributes!).with('name' => 'new name').
        and_raise(ActiveRecord::RecordInvalid.new(@notification_specification))
      put :update, :id => '1', :notification_specification => { 'name' => 'new name'}
      response.should render_template('edit')
    end
    
    it "should destroy existing notification_specification" do
      @notification_specification.should_receive(:destroy)
      delete :destroy, :id => '1'
      response.should redirect_to(notifications_path)
      flash[:notice].should == "Successfully deleted notification."
    end
    
  end
  
end