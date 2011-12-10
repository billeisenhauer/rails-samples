require 'spec_helper'

describe SiteStatistics do
  
  before(:each) do
    @site = Factory.create(:site, :name => 'Parent')
    @valid_attributes = {
      :site_id         => @site.id,
      :collected_on    => Date.today,
      :active_assets   => 15,
      :archived_assets => 2,
      :tagged_assets   => 5
    }
  end
  
  ### VALIDATIONS ###

  it "should create a new instance given valid attributes" do
    SiteStatistics.create!(@valid_attributes)
  end
  
  it "should be invalid without site" do
    site_stat = SiteStatistics.new
    site_stat.should_not be_valid
    site_stat.should have(1).error_on(:site)
  end
  
  it "should be invalid without collected_on" do
    site_stat = SiteStatistics.new
    site_stat.should_not be_valid
    site_stat.should have(1).error_on(:collected_on)
  end

  it "should be invalid without active_assets count" do
    site_stat = SiteStatistics.new(:active_assets => -1)
    site_stat.should_not be_valid
    site_stat.should have(1).error_on(:active_assets)
  end
  
  it "should be invalid without archived_assets count" do
    site_stat = SiteStatistics.new(:archived_assets => -1)
    site_stat.should_not be_valid
    site_stat.should have(1).error_on(:archived_assets)
  end
  
  it "should be invalid without tagged_assets count" do
    site_stat = SiteStatistics.new(:tagged_assets => -1)
    site_stat.should_not be_valid
    site_stat.should have(1).error_on(:tagged_assets)
  end
  
  ### FINDERS / NAMED SCOPES ###
  
  it "should return statistics for the given date" do
    date = Date.today
    site = Factory.create(:site)
    site_stats = SiteStatistics.create!(
      :site_id => site.id, 
      :collected_on => date,
      :active_assets => 10,
      :archived_assets => 2,
      :tagged_assets => 5
    )
    SiteStatistics.create!(
      :site_id => site.id, 
      :collected_on => 1.day.ago,
      :active_assets => 10,
      :archived_assets => 2,
      :tagged_assets => 5
    )
    SiteStatistics.for_date(date).should eql([site_stats])
  end
  
  
  ### MANAGE ###
  
  it "should collect and notify for a given date" do
    site = Site.roots.first
    date = Date.today
    SiteStatistics.should_receive(:collect).with(site, date)
    SiteStatistics.should_receive(:notify).with(date)
    SiteStatistics.collect_and_notify
  end
  
  ### DELIVERY ###
  
  it "should deliver notification" do
    date = Date.today
    SiteStatistics.should_receive(:for_date).with(date).and_return([])
    SiteStatisticsMailer.should_receive(:deliver_statistics_notification).
      with(date, [])
    SiteStatistics.notify(date)
  end
  
  ### COUNTS ###
  
  it "should create counts for a site/date" do
    date = Date.today
    site = Factory.create(:site)
    InventoryAsset.should_receive(:active_assets_count).with(site, date).and_return(12)
    InventoryAsset.should_receive(:archived_assets_count).with(site, date).and_return(3)
    InventoryAsset.should_receive(:tagged_assets_count).with(site).and_return(6)
    lambda do
      SiteStatistics.collect(site, date)
    end.should change{ SiteStatistics.count }.by(1)
  end
  
  it "should update existing counts for a site/date" do
    date = Date.today
    site = Factory.create(:site)
    site_stats = SiteStatistics.create!(
      :site_id => site.id, 
      :collected_on => date,
      :active_assets => 10,
      :archived_assets => 2,
      :tagged_assets => 5
    )
    InventoryAsset.should_receive(:active_assets_count).with(site, date).and_return(12)
    InventoryAsset.should_receive(:archived_assets_count).with(site, date).and_return(3)
    InventoryAsset.should_receive(:tagged_assets_count).with(site).and_return(6)
    lambda do
      SiteStatistics.collect(site, date)
    end.should change{ SiteStatistics.count }.by(0)
  end
  
  ### MISCELLANEOUS ###
  
  it "should return 'Unknown Site' as name when no site" do 
    SiteStatistics.new.name.should eql('Unknown Site')
  end
  
  it "should return site ancestry name as name" do 
    child  = Site.create!(:name => 'Child', :parent_id => @site.id)
    SiteStatistics.new(:site => child).name.should eql('Parent > Child')
  end
   
end
