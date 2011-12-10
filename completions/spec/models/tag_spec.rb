require 'spec_helper'

describe Tag do

  before(:each) do
    @site = Factory.create(:site)
  end
  
  ### VALIDATIONS ###

  it "should create a new instance given valid attributes" do
    Tag.create!(Factory.attributes_for(:tag))
  end
  
  ### NAMED SCOPES / FINDERS ###
  
  it "should filter by site" do
    site = Factory.create(:site)
    expected_tag   = Factory.create(:tag, :site_id => @site.id)
    unexpected_tag = Factory.create(:tag, :site_id => site.id)
    Tag.for_site(@site).should eql([expected_tag])
  end   
  
  it "should return all sites for for_site if no site is given" do
    site = Factory.create(:site)
    a_tag = Factory.create(:tag, :site_id => @site.id)
    b_tag = Factory.create(:tag, :site_id => site.id)
    Tag.for_site.should eql([a_tag, b_tag])
  end
  
  it "should sort by site" do
    a_site = Factory.create(:site, :name => 'A')
    b_site = Factory.create(:site, :name => 'B')
    a_tag  = Factory.create(:tag, :site_id => a_site.id, :tag_number => '000.000.000.000')
    b_tag  = Factory.create(:tag, :site_id => b_site.id, :tag_number => '000.000.000.001')
    Tag.sorted_by('site asc').should eql([a_tag, b_tag])
    Tag.sorted_by('site desc').should eql([b_tag, a_tag])
  end
  
  it "should sort by tag number" do
    a_tag  = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.000')
    b_tag  = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.001')
    Tag.sorted_by('tag_number asc').should eql([a_tag, b_tag])
    Tag.sorted_by('tag_number desc').should eql([b_tag, a_tag])
  end
  
  # NOTE: Cannot figure out why thing method tries to find a missing mock_model
  # method. 
  #
  it "should sort by inventory asset" do
    a_asset = Factory.create(:inventory_asset, :po_number => '123')
    b_asset = Factory.create(:inventory_asset, :po_number => '321')
    a_tag   = Factory.create(:tag, :inventory_asset => a_asset)
    b_tag   = Factory.create(:tag, :inventory_asset => b_asset)
    Tag.sorted_by('inventory_asset asc').should eql([a_tag, b_tag])
    Tag.sorted_by('inventory_asset desc').should eql([b_tag, a_tag])
  end
  
  ### SEARCHING / FILTERING ###
  
  it "should search by tag_number" do
    a_tag = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.000')
    b_tag = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.001')
    Tag.search('001').should eql([b_tag])   
  end
  
  it "should return expected list options" do
    list_option_names = Tag.list_option_names
    [:sorted_by, :for_site, :search].each { |o| list_option_names.should include(o) }
  end
  
  it "should filter for site and order by tag_number asc" do
    a_site = Factory.create(:site, :name => 'A')
    b_site = Factory.create(:site, :name => 'B')
    a1_tag = Factory.create(:tag, :site_id => a_site.id, :tag_number => '000.000.000.000')
    a2_tag = Factory.create(:tag, :site_id => a_site.id, :tag_number => '000.000.000.001')
    b1_tag = Factory.create(:tag, :site_id => b_site.id, :tag_number => '000.000.000.002')
    list_options = {
      :for_site  => a_site,
      :sorted_by => 'tag_number asc'
    }
    Tag.filter(list_options).should eql([a1_tag, a2_tag])
  end
  
  it "should filter for site and order by name desc" do
    a_site = Factory.create(:site, :name => 'A')
    b_site = Factory.create(:site, :name => 'B')
    a1_tag = Factory.create(:tag, :site_id => a_site.id, :tag_number => '000.000.000.000')
    a2_tag = Factory.create(:tag, :site_id => a_site.id, :tag_number => '000.000.000.001')
    b1_tag = Factory.create(:tag, :site_id => b_site.id, :tag_number => '000.000.000.002')
    list_options = {
      :for_site  => a_site,
      :sorted_by => 'tag_number desc'
    }
    Tag.filter(list_options).should eql([a2_tag, a1_tag])
  end
  
  ### INVENTORY TAG SYNCHRONIZATION ###
  
  it "should update assigned inventory for tag reports" do    
    asset = Factory.create(:inventory_asset, :site_id => @site.id, :po_number => '123')
    tag   = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.002')
    tag.inventory_asset = asset
    last_reported_at = DateTime.now
    tag.update_attributes(:last_location => 'HERE', :last_reported_at => last_reported_at)
    asset.reload
    asset.last_seen_location.should eql(tag.last_location)
    asset.last_seen_at.should eql(tag.last_reported_at.in_time_zone.to_s(:us_with_time))
  end
  
  ### MISCELLANEOUS ###
  
  it "should return no site name if no site is set" do
    Tag.new.site_name.should eql('No site')
  end
  
  it "should return site name" do
    Tag.new(:site => @site).site_name.should eql(@site.name)
  end
  
  it "should return no inventory name if no inventory asset is set" do
    Tag.new.inventory_asset_name.should eql('Unassigned')
  end
  
  it "should return inventory asset name" do
    inventory_asset = InventoryAsset.new(:po_number => '123')
    Tag.new(:inventory_asset => inventory_asset).inventory_asset_name.should eql('123')
  end
  
  it "should calculate unseen days count" do
    tag = Tag.new(:last_reported_at => 2.days.ago)
    tag.unseen_days_count.should eql(2)
  end
  
end
