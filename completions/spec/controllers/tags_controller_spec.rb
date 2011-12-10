require File.dirname(__FILE__) + '/../spec_helper'

describe TagsController, "#route_for" do

  it "should map { :controller => 'tags', :action => 'index' } to /tags" do
    route_for(:controller => "tags", :action => "index").should == "/tags"
  end
  
  it "should map { :controller => 'tags', :action => 'new' } to /tags/new" do
    route_for(:controller => "tags", :action => "new").should == "/tags/new"
  end
  
  it "should map { :controller => 'tags', :action => 'show', :id => '1' } to /tags/1" do
    route_for(:controller => "tags", :action => "show", :id => '1').should == "/tags/1"
  end
  
  it "should map { :controller => 'tags', :action => 'edit', :id => '1' } to /tags/1/edit" do
    route_for(:controller => "tags", :action => "edit", :id => '1').should == "/tags/1/edit"
  end
  
  it "should map { :controller => 'tags', :action => 'update', :id => '1' } to /tags/1" do
    route_for(:controller => "tags", :action => "update", :id => '1').should == {:path => '/tags/1', :method => :put}
  end
  
  it "should map { :controller => 'tags', :action => 'destroy', :id => '1' } to /tags/1" do
    route_for(:controller => "tags", :action => "destroy", :id => '1').should == {:path => '/tags/1', :method => :delete}
  end
  
  it "should map { :controller => 'tags', :action => 'edit_import' } to /tags/edit_import" do
    route_for(:controller => "tags", :action => "edit_import").should == {:path => '/tags/edit_import', :method => :get}
  end
  
  it "should map { :controller => 'tags', :action => 'import' } to /tags/edit_import" do
    route_for(:controller => "tags", :action => "import").should == {:path => '/tags/import', :method => :put}
  end
  
end

describe TagsController, "authentication checks" do
  
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
    @tag = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.001')
    activate_authlogic
    login
  end
  
  describe TagsController, 'bulk, index, and search' do
    
    it "should show index" do
      get :index
      response.should render_template('index')
    end
    
    it "should apply bulk site change " do
      Tag.should_receive(:find).with(['1', '2', '3']).and_return([@tag])
      @tag.should_receive(:update_attributes).with(:site_id => @site.id)
      put :bulk, :tag_ids => ["1", "2", "3"], :bulk_site => @site.id, :bulk_site_change => "Apply"
      response.should redirect_to(tags_path)
      flash[:notice].should == "Successfully assigned 1 tags to #{@site.name}."
    end
    
    it "should not apply bulk site change if site not found" do
      Tag.should_receive(:find).with(['1', '2', '3']).and_return([@tag])
      Site.should_receive(:find).with('99999').and_raise(ActiveRecord::RecordNotFound)
      put :bulk, :tag_ids => ["1", "2", "3"], :bulk_site => '99999', :bulk_site_change => "Apply"
      response.should redirect_to(tags_path)
      flash[:notice].should == "Don't know that site; nothing has been done."
    end
    
    it "should apply bulk changes " do
      Tag.should_receive(:find).with(['1', '2', '3']).and_return([@tag])
      @tag.should_receive(:destroy)
      put :bulk, :tag_ids => ["1", "2", "3"], :bulk_action => 'delete', :bulk_action_change => "Apply"
      response.should redirect_to(tags_path)
      flash[:notice].should == 'Successfully deleted 1 tags.'
    end
    
    it "should not apply bulk changes if no bulk action was passed" do
      Tag.should_receive(:find).with(['1', '2', '3']).and_return([@tag])
      put :bulk, :tag_ids => ["1", "2", "3"], :bulk_action => nil, :bulk_action_change => "Apply"
      response.should redirect_to(tags_path)
      flash[:error].should == "No action was selected; nothing has been done."
    end
    
    it "should not apply bulk changes if no tags passed" do
      put :bulk, :tag_ids => nil, :bulk_action_change => "Apply"
      response.should redirect_to(tags_path)
      flash[:error].should == "No tags were selected; nothing has been done."
    end    
    
  end
  
  describe TagsController, "creation" do
  
    it "should show new tag form" do
      get :new
      response.should render_template('new')
    end
    
    it "should create new tag" do
      new_tag_reader = Tag.new
      Tag.should_receive(:new).with('tag_number' => 'Newest', 'site' => @site).
        and_return(new_tag_reader)
      new_tag_reader.should_receive(:save!)
      post :create, :tag => {:tag_number => 'Newest', :site => @site}
      flash[:notice].should == "Successfully created tag."
      response.should redirect_to(tags_path)
    end
  
    it "should reject invalid new tag" do
      new_tag_reader = Tag.new
      Tag.should_receive(:new).and_return(new_tag_reader)
      new_tag_reader.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(new_tag_reader))
      post :create
      response.should render_template('new')
    end
  
  end

  describe TagsController, "show, edit, update, and destroy" do
  
    before(:each) do
      Tag.should_receive(:find).with('1').and_return(@tag)
    end
    
    it "should show tag form" do
      get :show, :id => '1'
      response.should render_template('show')
    end
    
    it "should show tag form" do
      get :edit, :id => '1'
      response.should render_template('edit')
    end

    it "should update existing tag" do
      @tag.should_receive(:update_attributes!).with('tag_number' => '000.000.000.002')
      put :update, :id => '1', :tag => { 'tag_number' => '000.000.000.002'}
      response.should redirect_to(tags_path)
      flash[:notice].should == "Successfully updated tag."
    end
    
    it "should not update existing tag" do
      @tag.should_receive(:update_attributes!).with('tag_number' => '000.000.000.002').
        and_raise(ActiveRecord::RecordInvalid.new(@tag))
      put :update, :id => '1', :tag => { 'tag_number' => '000.000.000.002'}
      response.should render_template('edit')
    end
    
    it "should destroy existing tag" do
      @tag.should_receive(:destroy)
      delete :destroy, :id => '1'
      response.should redirect_to(tags_path)
      flash[:notice].should == "Successfully deleted tag."
    end
    
  end
  
end