require 'spec_helper'

describe Category do
  
  before(:each) do
    @site = Factory.create(:site)
    @valid_attributes = {
      :site_id => @site.id,
      :name => 'Test'
    }
  end

  it "should create a new instance given valid attributes" do
    Category.create!(@valid_attributes)
  end
  
  it "should be invalid without site" do
    category = Category.new
    category.should_not be_valid
    category.should have(1).error_on(:site)
  end
  
  it "should be invalid without name" do
    category = Category.new
    category.should_not be_valid
    category.should have(1).error_on(:name)
  end
  
  ### CAN DESTROY / ALLOWS BULK CHANGES ###
  
  it "should be able to destroy unassigned category" do
    category = Category.new
    category.can_destroy?.should be_true
    category.allows_bulk_actions?.should be_true
  end
  
  it "should not be able to destroy assigned category" do
    category = Category.new
    category.stub!(:inventory_assets).and_return([InventoryAsset.new])
    category.can_destroy?.should be_false
    category.can_destroy?.should be_false
  end
  
  ### ANCESTRY NAMES ###
  
  it "should calculate ancestry names" do
    parent = Category.create!(:site_id => @site.id, :name => 'Parent')
    child  = Category.create!(:site_id => @site.id, :name => 'Child', :parent_id => parent.id)
    parent.ancestry_names.should eql('Parent')
    child.ancestry_names.should eql('Parent > Child')
  end
  
  ### NAMED SCOPES / FINDERS ###
  
  it "should filter by site" do
    site = Factory.create(:site)
    expected_category   = Category.create!(:site_id => @site.id, :name => 'Expected')
    unexpected_category = Category.create!(:site_id => site.id, :name => 'Unexpected')
    Category.for_site(@site).should eql([expected_category])
  end   
  
  it "should return all sites for for_site if no site is given" do
    site = Factory.create(:site)
    a_category   = Category.create!(:site_id => @site.id, :name => 'Expected')
    b_category = Category.create!(:site_id => site.id, :name => 'Unexpected')
    Category.for_site.should eql([a_category, b_category])
  end
  
  it "should sort by site" do
    a_site = Factory.create(:site, :name => 'A')
    b_site = Factory.create(:site, :name => 'B')
    a_category   = Category.create!(:site_id => a_site.id, :name => 'A')
    b_category = Category.create!(:site_id => b_site.id, :name => 'B')
    Category.sorted_by('site asc').should eql([a_category, b_category])
    Category.sorted_by('site desc').should eql([b_category, a_category])
  end
  
  it "should sort by name" do
    a_category   = Category.create!(:site_id => @site.id, :name => 'A')
    b_category = Category.create!(:site_id => @site.id, :name => 'B')
    Category.sorted_by('name asc').should eql([a_category, b_category])
    Category.sorted_by('name desc').should eql([b_category, a_category])
  end
  
  ### SEARCHING / FILTERING ###
  
  it "should search by name" do
    parent = Category.create!(:site_id => @site.id, :name => 'Parent')
    child  = Category.create!(:site_id => @site.id, :name => 'Child', :parent_id => parent.id)
    Category.search('Parent').should eql([parent, child])   
  end
  
  it "should search by hierarchy" do
    parent = Category.create!(:site_id => @site.id, :name => 'Parent')
    child  = Category.create!(:site_id => @site.id, :name => 'Child', :parent_id => parent.id)
    Category.search('Parent > Child').should eql([child])   
  end
  
  it "should return expected list options" do
    list_option_names = Category.list_option_names
    [:sorted_by, :for_site, :search].each { |o| list_option_names.should include(o) }
  end
  
  it "should filter for site and order by name asc" do
    a_site = Factory.create(:site, :name => 'A')
    b_site = Factory.create(:site, :name => 'B')
    a1_category = Category.create!(:site_id => a_site.id, :name => 'A1')
    a2_category = Category.create!(:site_id => a_site.id, :name => 'A2')
    b1_category = Category.create!(:site_id => b_site.id, :name => 'B1')
    list_options = {
      :for_site  => a_site,
      :sorted_by => 'name asc'
    }
    Category.filter(list_options).should eql([a1_category, a2_category])
  end
  
  it "should filter for site and order by name desc" do
    a_site = Factory.create(:site, :name => 'A')
    b_site = Factory.create(:site, :name => 'B')
    a1_category = Category.create!(:site_id => a_site.id, :name => 'A1')
    a2_category = Category.create!(:site_id => a_site.id, :name => 'A2')
    b1_category = Category.create!(:site_id => b_site.id, :name => 'B1')
    list_options = {
      :for_site  => a_site,
      :sorted_by => 'name desc'
    }
    Category.filter(list_options).should eql([a2_category, a1_category])
  end
  
end
