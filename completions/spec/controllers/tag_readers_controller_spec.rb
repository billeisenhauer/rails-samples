require 'spec_helper'

describe TagReadersController, "#route_for" do

  it "should map { :controller => 'tag_readers', :action => 'index' } to /tag_readers" do
    route_for(:controller => "tag_readers", :action => "index").should == "/tag_readers"
  end
  
  it "should map { :controller => 'tag_readers', :action => 'new' } to /tag_readers/new" do
    route_for(:controller => "tag_readers", :action => "new").should == "/tag_readers/new"
  end
  
  it "should map { :controller => 'tag_readers', :action => 'show', :id => '1' } to /tag_readers/1" do
    route_for(:controller => "tag_readers", :action => "show", :id => '1').should == "/tag_readers/1"
  end
  
  it "should map { :controller => 'tag_readers', :action => 'edit', :id => '1' } to /tag_readers/1/edit" do
    route_for(:controller => "tag_readers", :action => "edit", :id => '1').should == "/tag_readers/1/edit"
  end
  
  it "should map { :controller => 'tag_readers', :action => 'update', :id => '1' } to /tag_readers/1" do
    route_for(:controller => "tag_readers", :action => "update", :id => '1').should == {:path => '/tag_readers/1', :method => :put}
  end
  
  it "should map { :controller => 'tag_readers', :action => 'destroy', :id => '1' } to /tag_readers/1" do
    route_for(:controller => "tag_readers", :action => "destroy", :id => '1').should == {:path => '/tag_readers/1', :method => :delete}
  end
  
end

describe TagReadersController, "authentication checks" do
  
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
    @current_user = Factory.create(:support_administrator_user)
    @site = Factory.create(:site)
    SiteMembership.create(:user => @current_user, :site => @site)
    @tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :reader => 'name')
    activate_authlogic
    login
  end
  
  describe TagReadersController, 'bulk, index, and search' do
    
    it "should show index" do
      get :index
      response.should render_template('index')
    end
    
    it "should apply bulk site change " do
      TagReader.should_receive(:find).with(['1', '2', '3']).and_return([@tag_reader])
      @tag_reader.should_receive(:update_attributes).with(:site_id => @site.id)
      put :bulk, :tag_reader_ids => ["1", "2", "3"], :bulk_site => @site.id, :bulk_site_change => "Apply"
      response.should redirect_to(tag_readers_path)
      flash[:notice].should == "Successfully assigned 1 tag readers to #{@site.name}."
    end
    
    it "should not apply bulk site change if site not found" do
      TagReader.should_receive(:find).with(['1', '2', '3']).and_return([@tag_reader])
      Site.should_receive(:find).with('99999').and_raise(ActiveRecord::RecordNotFound)
      put :bulk, :tag_reader_ids => ["1", "2", "3"], :bulk_site => '99999', :bulk_site_change => "Apply"
      response.should redirect_to(tag_readers_path)
      flash[:notice].should == "Don't know that site; nothing has been done."
    end
    
    it "should apply bulk changes " do
      TagReader.should_receive(:find).with(['1', '2', '3']).and_return([@tag_reader])
      @tag_reader.should_receive(:destroy)
      put :bulk, :tag_reader_ids => ["1", "2", "3"], :bulk_action => 'delete', :bulk_action_change => "Apply"
      response.should redirect_to(tag_readers_path)
      flash[:notice].should == 'Successfully deleted 1 tag readers.'
    end
    
    it "should not apply bulk changes if no bulk action was passed" do
      TagReader.should_receive(:find).with(['1', '2', '3']).and_return([@tag_reader])
      put :bulk, :tag_reader_ids => ["1", "2", "3"], :bulk_action => nil, :bulk_action_change => "Apply"
      response.should redirect_to(tag_readers_path)
      flash[:error].should == "No action was selected; nothing has been done."
    end
    
    it "should not apply bulk changes if no tag readers passed" do
      put :bulk, :tag_reader_ids => nil, :bulk_action_change => "Apply"
      response.should redirect_to(tag_readers_path)
      flash[:error].should == "No tag readers were selected; nothing has been done."
    end    
    
  end
  
  describe TagReadersController, "creation" do
  
    it "should show new tag reader form" do
      get :new
      response.should render_template('new')
    end
    
    it "should create new tag reader" do
      new_tag_reader = TagReader.new
      TagReader.should_receive(:new).with('reader' => 'Newest', 'site' => @site).
        and_return(new_tag_reader)
      new_tag_reader.should_receive(:save!)
      post :create, :tag_reader => {:reader => 'Newest', :site => @site}
      flash[:notice].should == "Successfully created tag reader."
      response.should redirect_to(tag_readers_path)
    end
  
    it "should reject invalid new tag reader" do
      new_tag_reader = TagReader.new
      TagReader.should_receive(:new).and_return(new_tag_reader)
      new_tag_reader.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(new_tag_reader))
      post :create
      response.should render_template('new')
    end
  
  end

  describe TagReadersController, "show, edit, update, and destroy" do
  
    before(:each) do
      TagReader.should_receive(:find).with('1').and_return(@tag_reader)
    end
    
    it "should show tag reader form" do
      get :show, :id => '1'
      response.should render_template('show')
    end
    
    it "should show tag reader form" do
      get :edit, :id => '1'
      response.should render_template('edit')
    end

    it "should update existing tag reader" do
      @tag_reader.should_receive(:update_attributes!).with('reader' => 'new name')
      put :update, :id => '1', :tag_reader => { 'reader' => 'new name'}
      response.should redirect_to(tag_readers_path)
      flash[:notice].should == "Successfully updated tag reader."
    end
    
    it "should not update existing tag reader" do
      @tag_reader.should_receive(:update_attributes!).with('reader' => 'new name').
        and_raise(ActiveRecord::RecordInvalid.new(@tag_reader))
      put :update, :id => '1', :tag_reader => { 'reader' => 'new name'}
      response.should render_template('edit')
    end
    
    it "should destroy existing tag reader" do
      @tag_reader.should_receive(:destroy)
      delete :destroy, :id => '1'
      response.should redirect_to(tag_readers_path)
      flash[:notice].should == "Successfully deleted tag reader."
    end
    
  end
  
end
