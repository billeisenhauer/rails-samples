require 'spec_helper'

describe CategoriesController, "#route_for" do

  it "should map { :controller => 'categories', :action => 'index' } to /categories" do
    route_for(:controller => "categories", :action => "index").should == "/categories"
  end
  
  it "should map { :controller => 'categories', :action => 'new' } to /categories/new" do
    route_for(:controller => "categories", :action => "new").should == "/categories/new"
  end
  
  it "should map { :controller => 'categories', :action => 'show', :id => '1' } to /categories/1" do
    route_for(:controller => "categories", :action => "show", :id => '1').should == "/categories/1"
  end
  
  it "should map { :controller => 'categories', :action => 'edit', :id => '1' } to /categories/1/edit" do
    route_for(:controller => "categories", :action => "edit", :id => '1').should == "/categories/1/edit"
  end
  
  it "should map { :controller => 'categories', :action => 'update', :id => '1' } to /categories/1" do
    route_for(:controller => "categories", :action => "update", :id => '1').should == {:path => '/categories/1', :method => :put}
  end
  
  it "should map { :controller => 'categories', :action => 'destroy', :id => '1' } to /categories/1" do
    route_for(:controller => "categories", :action => "destroy", :id => '1').should == {:path => '/categories/1', :method => :delete}
  end
  
end

describe CategoriesController, "authentication checks" do
  
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
    @category = Factory.create(:category, :site_id => @site.id, :name => 'name')
    activate_authlogic
    login
  end
  
  describe CategoriesController, 'bulk, index, and search' do
    
    it "should show index" do
      get :index
      response.should render_template('index')
    end
    
    it "should apply bulk site change" do
      Category.should_receive(:find).with(['1', '2', '3']).and_return([@category])
      @category.should_receive(:update_attributes).with(:site_id => @site.id)
      put :bulk, :category_ids => ["1", "2", "3"], :bulk_site => @site.id, :bulk_site_change => "Apply"
      response.should redirect_to(categories_path)
      flash[:notice].should == "Successfully assigned 1 categories to #{@site.name}."
    end
    
    it "should not apply bulk site change if site not found" do
      Category.should_receive(:find).with(['1', '2', '3']).and_return([@category])
      Site.should_receive(:find).with('99999').and_raise(ActiveRecord::RecordNotFound)
      put :bulk, :category_ids => ["1", "2", "3"], :bulk_site => '99999', :bulk_site_change => "Apply"
      response.should redirect_to(categories_path)
      flash[:notice].should == "Don't know that site; nothing has been done."
    end
    
    it "should apply bulk deletes " do
      Category.should_receive(:find).with(['1', '2', '3']).and_return([@category])
      @category.should_receive(:destroy)
      put :bulk, :category_ids => ["1", "2", "3"], :bulk_action => 'delete', :bulk_action_change => "Apply"
      response.should redirect_to(categories_path)
      flash[:notice].should == 'Successfully deleted 1 categories.'
    end
    
    it "should not apply bulk deletes if no bulk action was passed" do
      Category.should_receive(:find).with(['1', '2', '3']).and_return([@category])
      put :bulk, :category_ids => ["1", "2", "3"], :bulk_action => nil, :bulk_action_change => "Apply"
      response.should redirect_to(categories_path)
      flash[:error].should == "No action was selected; nothing has been done."
    end
    
    it "should not apply bulk deletes if no categories passed" do
      put :bulk, :category_ids => nil, :bulk_action_change => "Apply"
      response.should redirect_to(categories_path)
      flash[:error].should == "No categories were selected; nothing has been done."
    end    
    
  end
  
  describe CategoriesController, "creation" do
  
    it "should show new category form" do
      get :new
      response.should render_template('new')
    end
    
    it "should create new category" do
      new_category = Category.new
      Category.should_receive(:new).with('name' => 'Newest', 'site' => @site).
        and_return(new_category)
      new_category.should_receive(:save!)
      post :create, :category => {:name => 'Newest', :site => @site}
      flash[:notice].should == "Successfully created category."
      response.should redirect_to(categories_path)
    end
  
    it "should reject invalid new category" do
      new_category = Category.new
      Category.should_receive(:new).and_return(new_category)
      new_category.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(new_category))
      post :create
      response.should render_template('new')
    end
  
  end

  describe CategoriesController, "show, edit, update, and destroy" do
  
    before(:each) do
      Category.should_receive(:find).with('1').and_return(@category)
    end
    
    it "should show category form" do
      get :show, :id => '1'
      response.should render_template('show')
    end
    
    it "should show category form" do
      get :edit, :id => '1'
      response.should render_template('edit')
    end

    it "should update existing category" do
      @category.should_receive(:update_attributes!).with('name' => 'new name')
      put :update, :id => '1', :category => { 'name' => 'new name'}
      response.should redirect_to(categories_path)
      flash[:notice].should == "Successfully updated category."
    end
    
    it "should not update existing category" do
      @category.should_receive(:update_attributes!).with('name' => 'new name').
        and_raise(ActiveRecord::RecordInvalid.new(@category))
      put :update, :id => '1', :category => { 'name' => 'new name'}
      response.should render_template('edit')
    end
    
    it "should destroy existing category" do
      @category.should_receive(:destroy)
      delete :destroy, :id => '1'
      response.should redirect_to(categories_path)
      flash[:notice].should == "Successfully deleted category."
    end
    
  end
  
end