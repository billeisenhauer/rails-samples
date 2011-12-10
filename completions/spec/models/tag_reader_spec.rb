require 'spec_helper'

describe TagReader do

  before(:each) do
    @site = Factory.create(:site)
  end
  
  ### VALIDATION ###

  it "should create a new instance given valid attributes" do
    TagReader.create!(Factory.attributes_for(:tag_reader).merge(:site => @site))
  end
  
  it "is not valid without address" do
    tag_reader = TagReader.new
    tag_reader.should_not be_valid
    tag_reader.should have(1).error_on(:address)
  end
  
  it "is not valid without latitude (if there is no address)" do
    tag_reader = TagReader.new
    tag_reader.should_not be_valid
    tag_reader.should have(2).error_on(:latitude)
  end
  
  it "is not valid with non-numeric latitude (if there is no address)" do
    tag_reader = TagReader.new(:latitude => 'A')
    tag_reader.should_not be_valid
    tag_reader.should have(1).error_on(:latitude)
  end
  
  it "is not valid without valid latitude (if there is no address)" do
    tag_reader = TagReader.new(:latitude => 100)
    tag_reader.should_not be_valid
    tag_reader.should have(1).error_on(:latitude)
  end
  
  it "is not valid without longitude (if there is no address)" do
    tag_reader = TagReader.new
    tag_reader.should_not be_valid
    tag_reader.should have(2).error_on(:longitude)
  end
  
  it "is not valid with non-numeric longitude (if there is no address)" do
    tag_reader = TagReader.new(:longitude => 'A')
    tag_reader.should_not be_valid
    tag_reader.should have(1).error_on(:longitude)
  end
  
  it "is not valid without valid longitude (if there is no address)" do
    tag_reader = TagReader.new(:longitude => 200)
    tag_reader.should_not be_valid
    tag_reader.should have(1).error_on(:longitude)
  end
  
  ### NAMED SCOPES / FINDERS ###
  
  it "should filter by site" do
    site = Factory.create(:site)
    expected_tag_reader   = Factory.create(:tag_reader, :site_id => @site.id)
    unexpected_tag_reader = Factory.create(:tag_reader, :site_id => site.id)
    TagReader.for_site(@site).should eql([expected_tag_reader])
  end   
  
  it "should return all sites for for_site if no site is given" do
    site = Factory.create(:site)
    a_tag_reader = Factory.create(:tag_reader, :site_id => @site.id)
    b_tag_reader = Factory.create(:tag_reader, :site_id => site.id)
    TagReader.for_site.should eql([a_tag_reader, b_tag_reader])
  end
  
  it "should sort by site" do
    a_site = Factory.create(:site, :name => 'A')
    b_site = Factory.create(:site, :name => 'B')
    a_tag_reader = Factory.create(:tag_reader, :site_id => a_site.id, :reader => 'AA')
    b_tag_reader = Factory.create(:tag_reader, :site_id => b_site.id, :reader => 'BB')
    TagReader.sorted_by('site asc').should eql([a_tag_reader, b_tag_reader])
    TagReader.sorted_by('site desc').should eql([b_tag_reader, a_tag_reader])
  end
  
  it "should sort by reader" do
    a_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :reader => 'AA')
    b_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :reader => 'BB')
    TagReader.sorted_by('reader asc').should eql([a_tag_reader, b_tag_reader])
    TagReader.sorted_by('reader desc').should eql([b_tag_reader, a_tag_reader])
  end
  
  it "should find unreported tag readers defaulting for 1 day ago" do
    a_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :last_reported_at => Time.now)
    b_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :last_reported_at => 3.days.ago)
    TagReader.unreported.should eql([b_tag_reader])
  end
  
  it "should find unreported tag readers 3 day ago" do
    a_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :last_reported_at => 2.days.ago)
    b_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :last_reported_at => 4.days.ago)
    TagReader.unreported(3.days.ago).should eql([b_tag_reader])
  end
  
  ### SEARCHING / FILTERING ###
  
  it "should search by reader" do
    a_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :reader => 'ZZ')
    b_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :reader => 'XX')
    TagReader.search('ZZ').should eql([a_tag_reader])   
  end
  
  it "should search by address" do
    a_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :address => 'STOCKROOM')
    b_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :reader => 'YARD')
    TagReader.search('YARD').should eql([b_tag_reader])   
  end
  
  it "should return expected list options" do
    list_option_names = TagReader.list_option_names
    [:sorted_by, :for_site, :search].each { |o| list_option_names.should include(o) }
  end
  
  it "should filter for site and order by name asc" do
    a_site = Factory.create(:site, :name => 'A')
    b_site = Factory.create(:site, :name => 'B')
    a1_tr = Factory.create(:tag_reader, :site_id => a_site.id, :reader => 'A1')
    a2_tr = Factory.create(:tag_reader, :site_id => a_site.id, :reader => 'A2')
    b1_tr = Factory.create(:tag_reader, :site_id => b_site.id, :reader => 'B1')
    list_options = {
      :for_site  => a_site,
      :sorted_by => 'reader asc'
    }
    TagReader.filter(list_options).should eql([a1_tr, a2_tr])
  end
  
  it "should filter for site and order by name desc" do
    a_site = Factory.create(:site, :name => 'A')
    b_site = Factory.create(:site, :name => 'B')
    a1_tr = Factory.create(:tag_reader, :site_id => a_site.id, :reader => 'A1')
    a2_tr = Factory.create(:tag_reader, :site_id => a_site.id, :reader => 'A2')
    b1_tr = Factory.create(:tag_reader, :site_id => b_site.id, :reader => 'B1')
    list_options = {
      :for_site  => a_site,
      :sorted_by => 'reader desc'
    }
    TagReader.filter(list_options).should eql([a2_tr, a1_tr])
  end
  
  ### NOTIFICATION ###
  
  it "should calculate unreported days count" do
    tag_reader = TagReader.new(:last_reported_at => 2.days.ago)
    tag_reader.unreported_days_count.should eql(2)
  end
  
  it "should notify for unreporting tag readers" do
    a_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :last_reported_at => Time.now)
    b_tag_reader = Factory.create(:tag_reader, :site_id => @site.id, :last_reported_at => 2.days.ago)
    TagReaderMailer.should_receive(:deliver_unreported_notification).with(b_tag_reader).once
    TagReader.notify_for_unreporting_tag_readers
  end
  
  ### MISCELLANEOUS ###
  
  it "should return no site name if no site is set" do
    TagReader.new.site_name.should eql('No site')
  end
  
  it "should return site name" do
    TagReader.new(:site => @site).site_name.should eql(@site.name)
  end
  
  it "should return true if has address" do
    TagReader.new(:address => 'ADDRESS').address?.should be_true
  end
  
  it "should return false if no address" do
    TagReader.new.address?.should_not be_true
  end
  
  it "should be mapped with coordinates" do
    TagReader.new(:latitude => 32, :longitude => 90).mapped?.should be_true
  end
  
  it "should not be mapped without coordinates" do
    TagReader.new.mapped?.should_not be_true
  end

end
