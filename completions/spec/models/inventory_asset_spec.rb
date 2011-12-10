require File.dirname(__FILE__) + '/../spec_helper'

describe InventoryAsset do
  
  before(:each) do 
    @site = Factory.create(:site)
  end
  
  ### VALIDATIONS ###

  it "should create a new instance given valid attributes" do
    attrs = Factory.attributes_for(:inventory_asset).merge(:site => @site)
    InventoryAsset.create!(attrs)
  end
  
  it "should be invalid without site" do
    asset = InventoryAsset.new
    asset.should_not be_valid
    asset.should have(1).error_on(:site)
  end
  
  it "should be invalid with duplicate tag" do
    tag   = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.001')
    Factory.create(:inventory_asset, :tag => tag)
    asset = InventoryAsset.new(:tag => tag)
    asset.should_not be_valid
    asset.should have(1).error_on(:tag_id)
  end
  
  it "should not be invalid with non-numeric values" do
    [ 
      :unit_cost_amount,
      :engineering_amount,
      :additional_amount,
      :shipping_amount,
      :total_cost_amount,
      :unit_sales_amount,
      :total_sales_amount,
      :cos
    ].each do |field|
      asset = Factory.create(:inventory_asset)
      asset.send("#{field}=", 'non-numeric')
      asset.should_not be_valid
      asset.should have(1).error_on(field)
    end
  end
  
  it "should not be invalid with negative values" do
    [ 
      :unit_cost_amount,
      :engineering_amount,
      :additional_amount,
      :shipping_amount,
      :total_cost_amount,
      :unit_sales_amount,
      :total_sales_amount,
      :cos
    ].each do |field|
      asset = Factory.create(:inventory_asset)
      asset.send("#{field}=", -1)
      asset.should_not be_valid
      asset.should have(1).error_on(field)
    end
  end
  
  it "should not be valid if red with missing fields" do
    asset = Factory.create(:inventory_asset)
    asset.po_number  = nil
    asset.ordered_on = nil
    asset.should_not be_valid
    asset.should have(1).error_on(:po_number)
    asset.should have(1).error_on(:ordered_on)
  end
  
  ### STATE MANGEMENT ###
  
  it "should default to red when created" do
    asset = Factory.create(:inventory_asset)
    asset.state.should eql('red')
  end
  
  it "should transition to yellow when received" do
    asset = Factory.create(:inventory_asset)
    asset.update_attributes(:gr => true, :gr_on => Date.today)
    asset.state.should eql('yellow')
  end
  
  it "should transition to green if received then sold" do
    asset = Factory.create(:yellow)
    asset.update_attributes(:fo => true, :fo_on => Date.today)
    asset.state.should eql('green')
  end
  
  it "should transition to blue if received then sold then installed" do
    asset = Factory.create(:green)
    asset.update_attributes(:installed_on => Date.today)
    asset.state.should eql('blue')
  end
    
  ### ATTRIBUTES ###
  
  it "should default to zero for nil values for certain field" do
    InventoryAsset.new.days_lead_time.should eql(0)
    InventoryAsset.new.quantity_ordered.should eql(0)
    InventoryAsset.new.quantity_installed.should eql(0)
    InventoryAsset.new.quantity_on_location.should eql(0)
  end
  
  it "should recognize state change" do
    InventoryAsset.new(:state => 'green').state_change?.should be_true
  end
  
  it "should recognize last seen location change" do
    InventoryAsset.new(:last_seen_location => 'SOMEWHERE').location_change?.should be_true
  end
  
  it "should show as OUT if no last seen location" do
    InventoryAsset.new.last_seen_location.should eql('OUT')
  end
  
  it "should show last seen location if exists" do
    InventoryAsset.new(:last_seen_location => 'SOMEWHERE').last_seen_location.should eql('SOMEWHERE')
  end
  
  it "should show as Uncategorized if no category" do
    InventoryAsset.new.category_name.should eql('Uncategorized')
  end
  
  it "should show as category name given category assignment" do
    category =  Factory.create(:category, :name => 'Category')
    InventoryAsset.new(:category => category).category_name.should eql('Category')
  end
  
  it "should show as '' if no site" do
    InventoryAsset.new.site_name.should be_empty
  end
  
  it "should show as site name given site assignment" do
    site = Factory.create(:site, :name => 'Site')
    InventoryAsset.new(:site => site).site_name.should eql('Site')
  end
  
  it "should show as 'None' if no PE" do
    InventoryAsset.new.pe_name.should eql('None')
  end
  
  it "should show as PE name given PE assignment" do
    user = Factory.create(:user)
    InventoryAsset.new(:pe => user).pe_name.should eql(user.display_name)
  end
  
  it "should show as 'None' if no TR" do
    InventoryAsset.new.tr_assignment_name.should eql('None')
  end
  
  it "should show as TR name given TR assignment" do
    user = Factory.create(:user)
    InventoryAsset.new(:tr_assignment => user).tr_assignment_name.should eql(user.display_name)
  end
  
  it "should show as 'Untagged' if no tag" do
    InventoryAsset.new.tag_number.should eql('Untagged')
  end
  
  it "should show as tag number given tag assignment" do
    tag = Factory.create(:tag)
    InventoryAsset.new(:tag => tag).tag_number.should eql(tag.tag_number)
  end
  
  it "should show as 'Never' if no last seen at" do
    InventoryAsset.new.last_seen_at.should eql('Never')
  end
  
  it "should show as last seen if value has been set" do
    seen_at = DateTime.now
    InventoryAsset.new(:last_seen_at => seen_at).last_seen_at.should eql(seen_at.in_time_zone.to_s(:us_with_time))
  end
  
  it "should show as last seen if value has been set using user timezone" do
    seen_at = DateTime.now
    user = Factory.create(:user, :time_zone => 'Central Time (US & Canada)')
    InventoryAsset.new(:last_seen_at => seen_at).last_seen_at(user).should eql(seen_at.in_time_zone.to_s(:us_with_time))
  end
  
  it "should show as 'NO' if no gr" do
    InventoryAsset.new.gr_value.should eql('NO')
    InventoryAsset.new(:gr => false).gr_value.should eql('NO')
  end
  
  it "should show as 'YES' if gr is true" do
    InventoryAsset.new(:gr => true).gr_value.should eql('YES')
  end
  
  it "should show as 'Unreviewed' if no tr status" do
    InventoryAsset.new.tr_status_value.should eql('Unreviewed')
  end
  
  it "should show as 'FAIL' if tr status is false" do
    InventoryAsset.new(:tr_status => false).tr_status_value.should eql('FAIL')
  end
  
  it "should show as 'PASS' if tr status is true" do
    InventoryAsset.new(:tr_status => true).tr_status_value.should eql('PASS')
  end
  
  it "should show as '' if no date set" do
    [
      :ordered_on, :expected_delivery_on, :actual_delivery_on, :gr_on, :tr_on,
      :fo_on, :installed_on, :delivery_on
    ].each do |date_attr|
      InventoryAsset.new.send("#{date_attr}_value").should be_empty
    end
  end
  
  it "should show as date if value has been set" do
    date = Date.new(2010, 7, 4)    
    [
      :ordered_on, :expected_delivery_on, :actual_delivery_on, :gr_on, :tr_on,
      :fo_on, :installed_on, :delivery_on
    ].each do |date_attr|
      InventoryAsset.new(date_attr => date).send("#{date_attr}_value").should eql('07/04/10')
    end
  end
  
  ### FINDERS / NAMED SCOPES ###
  
  it "should return only inventory for a particular site" do
    site = Factory.create(:site)
    expected   = Factory.create(:inventory_asset, :site => @site)
    unexpected = Factory.create(:inventory_asset, :site => site)
    InventoryAsset.only_at_site(@site).should eql([expected])
  end
  
  it "should return inventory for a site and its downward hierarchy" do
    parent_site = Factory.create(:site)
    child_site  = Factory.create(:site, :parent => parent_site)
    expected_1   = Factory.create(:inventory_asset, :site => parent_site)
    expected_2   = Factory.create(:inventory_asset, :site => child_site)
    unexpected = Factory.create(:inventory_asset, :site => @site)
    InventoryAsset.for_site(parent_site).should eql([expected_1, expected_2])
    InventoryAsset.for_site(child_site).should eql([expected_2])
  end
  
  it "should return no inventory when no site given for for site scope" do
    unexpected = Factory.create(:inventory_asset, :site => @site)
    InventoryAsset.for_site.should eql([])
  end
  
  it "should return only inventory for a particular state" do
    expected   = Factory.create(:inventory_asset, :state => 'red')
    unexpected = Factory.create(:inventory_asset, :gr => true, :gr_on => Date.today)
    InventoryAsset.for_state('red').should eql([expected])
  end
  
  it "should return no inventory when no site given for for site scope" do
    expected_1 = Factory.create(:inventory_asset)
    expected_2 = Factory.create(:inventory_asset)
    InventoryAsset.for_state.should eql([expected_1, expected_2])
  end
  
  it "should return inventory sorted by tag number" do
    tag_1      = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.001')
    tag_2      = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.002')
    expected_1 = Factory.create(:inventory_asset, :tag => tag_1)
    expected_2 = Factory.create(:inventory_asset, :tag => tag_2)
    InventoryAsset.sorted_by('tag_number asc').should eql([expected_1, expected_2])
    InventoryAsset.sorted_by('tag_number desc').should eql([expected_2, expected_1])
  end
  
  it "should return inventory sorted by category" do
    category_1 = Category.create!(:site_id => @site.id, :name => 'A1')
    category_2 = Category.create!(:site_id => @site.id, :name => 'A2')
    expected_1 = Factory.create(:inventory_asset, :category => category_1)
    expected_2 = Factory.create(:inventory_asset, :category => category_2)
    InventoryAsset.sorted_by('category asc').should eql([expected_1, expected_2])
    InventoryAsset.sorted_by('category desc').should eql([expected_2, expected_1])
  end
  
  it "should return inventory sorted by pe user name" do
    user_1     = Factory.create(:user, :name => 'A1')
    user_2     = Factory.create(:user, :name => 'A2')
    expected_1 = Factory.create(:inventory_asset, :pe => user_1)
    expected_2 = Factory.create(:inventory_asset, :pe => user_2)
    InventoryAsset.sorted_by('pe asc').should eql([expected_1, expected_2])
    InventoryAsset.sorted_by('pe desc').should eql([expected_2, expected_1])
  end
  
  it "should return inventory sorted by tr user name" do
    user_1     = Factory.create(:user, :name => 'A1')
    user_2     = Factory.create(:user, :name => 'A2')
    expected_1 = Factory.create(:inventory_asset, :tr_assignment => user_1)
    expected_2 = Factory.create(:inventory_asset, :tr_assignment => user_2)
    InventoryAsset.sorted_by('tr_assignment asc').should eql([expected_1, expected_2])
    InventoryAsset.sorted_by('tr_assignment desc').should eql([expected_2, expected_1])
  end
  
  it "should return inventory sorted by part number (a random string field)" do
    expected_1 = Factory.create(:inventory_asset, :part_number => 'AAAAA')
    expected_2 = Factory.create(:inventory_asset, :part_number => 'BBBBB')
    InventoryAsset.sorted_by('part_number asc').should eql([expected_1, expected_2])
    InventoryAsset.sorted_by('part_number desc').should eql([expected_2, expected_1])
  end
  
  it "should return inventory sorted by days lead time (a random number field)" do
    expected_1 = Factory.create(:inventory_asset, :days_lead_time => 10)
    expected_2 = Factory.create(:inventory_asset, :days_lead_time => 20)
    InventoryAsset.sorted_by('days_lead_time asc').should eql([expected_1, expected_2])
    InventoryAsset.sorted_by('days_lead_time desc').should eql([expected_2, expected_1])
  end
  
  it "should return inventory sorted by gr_on (a random date field)" do
    expected_1 = Factory.create(:inventory_asset, :gr_on => 1.day.ago)
    expected_2 = Factory.create(:inventory_asset, :gr_on => Date.today)
    InventoryAsset.sorted_by('gr_on asc').should eql([expected_1, expected_2])
    InventoryAsset.sorted_by('gr_on desc').should eql([expected_2, expected_1])
  end
  
  it "should return tagged and untagged inventory" do
    tag      = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.001')
    tagged   = Factory.create(:inventory_asset, :tag => tag)
    untagged = Factory.create(:inventory_asset)
    InventoryAsset.tagged.should eql([tagged])
    InventoryAsset.untagged.should eql([untagged])
  end
  
  ### SEARCHING / FILTERING ###
  
  it "should search by po number" do
    expected = Factory.create(:inventory_asset, :po_number => '12345')
    Factory.create(:inventory_asset, :po_number => '54321')
    InventoryAsset.search('12345').should eql([expected])   
  end
  
  it "should search by category" do
    category = Category.create!(:site_id => @site.id, :name => 'Category')
    expected = Factory.create(:inventory_asset, :category => category)
    Factory.create(:inventory_asset, :po_number => '54321')
    InventoryAsset.search('Category').should eql([expected])  
  end
  
  it "should search by pe user" do
    user_1     = Factory.create(:user, :name => 'A1')
    user_2     = Factory.create(:user, :name => 'A2')
    expected = Factory.create(:inventory_asset, :pe => user_1)
    Factory.create(:inventory_asset, :pe => user_2)
    InventoryAsset.search('A1').should eql([expected])  
  end
  
  it "should search by tr assignment user" do
    user_1     = Factory.create(:user, :name => 'A1')
    user_2     = Factory.create(:user, :name => 'A2')
    expected = Factory.create(:inventory_asset, :tr_assignment => user_1)
    Factory.create(:inventory_asset, :pe => user_2)
    InventoryAsset.search('A1').should eql([expected])  
  end
  
  it "should return expected list options" do
    list_option_names = Category.list_option_names
    [:sorted_by, :for_site, :search].each { |o| list_option_names.should include(o) }
  end
  
  it "should filter for site and order by po_number asc" do
    a_site = Factory.create(:site, :name => 'A')
    b_site = Factory.create(:site, :name => 'B')
    a1_asset = Factory.create(:inventory_asset, :site => a_site, :po_number => 'A2')
    a2_asset = Factory.create(:inventory_asset, :site => a_site, :po_number => 'A1')
    b1_asset = Factory.create(:inventory_asset, :site => b_site, :po_number => 'B1')
    list_options = {
      :for_site  => a_site,
      :sorted_by => 'po_number asc'
    }
    InventoryAsset.filter(list_options).should eql([a2_asset, a1_asset])
  end
  
  ### INVENTORY STATUS ###
  
  it "should return 0 for unseen days count if untagged" do
    asset = Factory.create(:inventory_asset)
    asset.unseen_days_count.should be_zero
  end
  
  it "should defer to tag for unseen days count when tagged" do
    tag   = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.001')
    tag.should_receive(:unseen_days_count).and_return(10)
    asset = Factory.create(:inventory_asset, :tag => tag)
    asset.unseen_days_count.should eql(10)
  end
  
  it "should check out inventory" do
    asset = Factory.create(:inventory_asset, :po_number => '12345', :last_seen_location => 'IN')
    asset.out!
    asset.last_seen_location.should eql('OUT')
  end
  
  it "should return unseen assets and check them out" do
    non_working_reader = Factory.create(:tag_reader, :site_id => @site.id, :last_reported_at => 2.days.ago)
    working_reader     = Factory.create(:tag_reader, :site_id => @site.id, :last_reported_at => 30.minutes.ago)
    tag_with_non_working_reader = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.001')
    tag_with_working_reader_in  = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.002')
    tag_with_working_reader_out = Factory.create(:tag, :site_id => @site.id, :tag_number => '000.000.000.003')
    TagReading.create(:tag => tag_with_non_working_reader, :tag_reader => non_working_reader, :updated_at => 2.days.ago)
    TagReading.create(:tag => tag_with_working_reader_in, :tag_reader => working_reader, :updated_at => Time.now)
    TagReading.create(:tag => tag_with_working_reader_out, :tag_reader => working_reader, :updated_at => 1.day.ago)
    Factory.create(:inventory_asset, :tag => tag_with_non_working_reader)
    Factory.create(:inventory_asset, :tag => tag_with_working_reader_in)
    expected_asset = Factory.create(:inventory_asset, :tag => tag_with_working_reader_out)
    InventoryAsset.unseen.should eql([expected_asset])
    InventoryAsset.checkout_unseen_assets
    expected_asset.last_seen_location.should eql('OUT')
  end
  
  ### SPLIT SUPPORT ###
  
  it "should be a split lot" do
    parent_asset = Factory.create(:inventory_asset)
    asset = Factory.create(:inventory_asset, :parent_asset_lot => parent_asset)
    asset.split_lot?.should be_true
    asset.original_lot?.should_not be_true
  end
  
  it "should not be a split lot" do
    asset = Factory.create(:inventory_asset)
    asset.split_lot?.should_not be_true
    asset.original_lot?.should be_true
  end
  
  it "should be splittable" do
    asset = Factory.create(:yellow, :serial_number => nil, :quantity_on_location => 10)
    asset.splittable?.should be_true
  end
  
  it "should not be splittable with serial number" do
    asset = Factory.create(:yellow, :serial_number => '12345', :quantity_on_location => 10)
    asset.splittable?.should_not be_true
  end
  
  it "should not be splittable with no quantity on location" do
    asset = Factory.create(:yellow, :serial_number => nil)
    asset.splittable?.should_not be_true
  end
  
  it "should instantiate split asset from asset" do
    category = Category.create!(:site_id => @site.id, :name => 'A1')
    parent_asset = Factory.create(
      :inventory_asset,
      :rfq_number => '555555',
      :vendor => 'VENDOR',
      :po_number => '111111',
      :ordered_on => 90.days.ago,
      :days_lead_time => 30,
      :expected_delivery_on => 80.days.ago,
      :category_id => category.id,
      :part_number => '6666666',
      :description => 'This is the description',
      :unit_cost_amount => 1000.00,
      :engineering_amount => 500.00,
      :additional_amount => 400.00,
      :shipping_amount => 200.00,
      :site_id => @site.id,
      :quantity_ordered => 60,
      :quantity_on_location => 60,
      :quantity_installed => 10
    )
    child_asset = InventoryAsset.split_from(parent_asset)
    child_asset.parent_asset_lot.should eql(parent_asset)
    InventoryAsset::CLONEABLE_ATTRIBUTES.each do |attr|
      child_asset.send(attr).should eql(parent_asset.send(attr))
    end
    # child_asset.split!
  end
  
end
