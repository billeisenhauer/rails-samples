require File.dirname(__FILE__) + '/../spec_helper'

describe Site do
  
  before(:each) do
    Factory.create(:guest_role)
    @user = Factory.create(:user)
  end
  
  ### VALIDATIONS ###
  
  it "is valid with valid attributes" do
    Site.new(Factory.attributes_for(:site)).should be_valid
  end
  
  it "is not valid without a name" do
    site = Site.new(:name => nil)
    site.should_not be_valid
    site.should have(1).error_on(:name)
  end
  
  ### MEMBERS / MEMBERSHIP ###
 
  it "should not detect leaf-level membership for unknown user" do
    parent_site = Factory.create(:site)
    site = parent_site.children.create(:name => 'child')
    SiteMembership.create(:user => @user, :site => site)
    user = Factory.create(:user)
    site.member?(user).should eql(false)
  end
  
  it "should detect leaf-level membership for user" do
    parent_site = Factory.create(:site)
    site = parent_site.children.create(:name => 'child')
    SiteMembership.create(:user => @user, :site => site)
    site.member?(@user).should eql(true)
  end
  
  it "should have no members" do
    parent_site = Factory.create(:site)
    site = parent_site.children.create(:name => 'child')
    site.all_users.should eql([])
  end
  
  it "should not detect top-level membership for unknown user" do
    parent_site = Factory.create(:site)
    site = parent_site.children.create(:name => 'child')
    SiteMembership.create(:user => @user, :site => parent_site)
    user = Factory.create(:user)
    parent_site.member?(user).should eql(false)
  end
  
  it "should detect top-level membership for user" do
    parent_site = Factory.create(:site)
    SiteMembership.create(:user => @user, :site => parent_site)
    parent_site.member?(@user).should eql(true)
  end
  
  it "should have no members" do
    parent_site = Factory.create(:site)
    parent_site.all_users.should eql([])
  end  
  
  it "should have one leaf-level user" do
    site = Factory.create(:site)
    SiteMembership.create(:user => @user, :site => site)
    site.all_users.should eql([@user])
  end  
  
  it "should have one top-level user" do
    parent_site = Factory.create(:site)
    SiteMembership.create(:user => @user, :site => parent_site)
    parent_site.all_users.should eql([@user])
  end
  
  ### ANCESTRY ###
  
  it "should have no descendents at top level" do
    parent_site = Factory.create(:site)
    parent_site.descendant_users.should eql([])
  end
  
  it "should have no descendents at leaf level" do
    parent_site = Factory.create(:site)
    site = parent_site.children.create(:name => 'child')
    site.descendant_users.should eql([])
  end
  
  it "should have one descendent at top level" do
    parent_site = Factory.create(:site)
    site = parent_site.children.create(:name => 'child')
    SiteMembership.create(:user => @user, :site => site)
    parent_site.descendant_users.should eql([@user])
  end
  
  ### NAMED SCOPES / FINDERS ###
  
  it "should filter by site" do
    parent_site = Factory.create(:site)
    site = parent_site.children.create(:name => 'child')
    unrelated_site = Factory.create(:site)
    Site.for_site(parent_site).should eql([parent_site, site])
  end   
  
  it "should return all sites for for_site if no site is given" do
    parent_site = Factory.create(:site)
    site = parent_site.children.create(:name => 'child')
    Site.for_site.should eql([parent_site, site])
  end
  
  it "should sort by name" do
    a_site = Site.create!(:name => 'A')
    b_site = Site.create!(:name => 'B')
    Site.sorted_by('name').should eql([a_site, b_site])
  end
  
  it "should sort by ancestry name" do
    a_site  = Site.create!(:name => 'A')
    b_site  = Site.create!(:name => 'B')
    a1_site = Site.create!(:name => 'A1', :parent_id => a_site.id)
    Site.sorted_by('ancestry_names').should eql([a_site, a1_site, b_site])
  end
  
  it "should return expected list options" do
    list_option_names = Category.list_option_names
    [:sorted_by, :for_site, :search].each { |o| list_option_names.should include(o) }
  end
  
  ### SEARCHING / FILTERING
  
  it "should filter for site and order by name asc" do
    a_site  = Site.create!(:name => 'A')
    b_site  = Site.create!(:name => 'B')
    a1_site = Site.create!(:name => 'A1', :parent_id => a_site.id)
    list_options = {
      :for_site  => a_site,
      :sorted_by => 'name'
    }
    Site.filter(list_options).should eql([a_site, a1_site])
  end
  
  it "should search by name" do
    parent = Site.create!(:name => 'Parent')
    child  = Site.create!(:name => 'Child', :parent_id => parent.id)
    Site.search('Parent').should eql([parent, child])   
  end
  
  it "should search by hierarchy" do
    parent = Site.create!(:name => 'Parent')
    child  = Site.create!(:name => 'Child', :parent_id => parent.id)
    Site.search('Parent > Child').should eql([child])   
  end
  
  ### DESTROY ###

  it "should not destroy site with assigned users" do
    site = Factory.create(:site, :name => 'A')
    user = Factory.create(:user)
    Factory.create(:site_membership, :site => site, :user => user)
    lambda do
      site.destroy
    end.should change{ Site.count }.by(0)
  end
  
  it "should not destroy site with assigned tags" do
    site = Factory.create(:site, :name => 'A')
    Factory.create(:tag, :site_id => site.id)
    lambda do
      site.destroy
    end.should change{ Site.count }.by(0)
  end
  
  it "should not destroy site with assigned categories" do
    site = Factory.create(:site, :name => 'A')
    Factory.create(:category, :site_id => site.id)
    lambda do
      site.destroy
    end.should change{ Site.count }.by(0)
  end
  
  it "should destroy site with no assigned categories, tags, or users" do
    site = Factory.create(:site, :name => 'A')
    lambda do
      site.destroy
    end.should change{ Site.count }.by(-1)
  end
  
  ### BULK ACTIONS ###
  
  it "should not allow bulk delete actions with assigned users" do
    site = Factory.create(:site, :name => 'A')
    user = Factory.create(:user)
    Factory.create(:site_membership, :site => site, :user => user)
    site.allows_bulk_actions?.should_not be_true
  end
  
  it "should not allow bulk delete actions with assigned tags" do
    site = Factory.create(:site, :name => 'A')
    Factory.create(:tag, :site_id => site.id)
    site.allows_bulk_actions?.should_not be_true
  end
  
  it "should not allow bulk delete actions with assigned categories" do
    site = Factory.create(:site, :name => 'A')
    Factory.create(:category, :site_id => site.id)
    site.allows_bulk_actions?.should_not be_true
  end
  
  it "should allow bulk delete actions with no assigned categories, tags, or users" do
    site = Factory.create(:site, :name => 'A')
    site.allows_bulk_actions?.should be_true
  end
  
  ### MEMBERSHIPS ###
  
  it "should hierarchically manage user memberships" do
    parent = Site.create!(:name => 'Parent')
    child  = Site.create!(:name => 'Child', :parent_id => parent.id)
    grandchild = Site.create!(:name => 'Grandchild', :parent_id => child.id)
    u1 = Factory.create(:user)
    Factory.create(:site_membership, :site => parent, :user => u1)
    u2 = Factory.create(:user)
    Factory.create(:site_membership, :site => child, :user => u2)
    u3 = Factory.create(:user)
    Factory.create(:site_membership, :site => grandchild, :user => u3)
    parent.all_users.should eql([u1, u2, u3])
    parent.all_users_count.should eql(3)
    parent.ancestor_users.should be_empty
    parent.members.should eql([u1, u2, u3])
    parent.descendant_users.should eql([u2, u3])
    
    child.all_users.should eql([u1, u2, u3])
    child.all_users_count.should eql(3)
    child.ancestor_users.should eql([u1])
    child.members.should eql([u2, u3])
    child.descendant_users.should eql([u3])
    
    grandchild.all_users.should eql([u1, u2, u3])
    grandchild.all_users_count.should eql(3)
    grandchild.ancestor_users.should eql([u1, u2])
    grandchild.members.should eql([u3])
    grandchild.descendant_users.should be_empty
  end
  
  ### TAGS ###
  
  it "should hierarchically manage tag assignments" do
    parent = Site.create!(:name => 'Parent')
    child  = Site.create!(:name => 'Child', :parent_id => parent.id)
    grandchild = Site.create!(:name => 'Grandchild', :parent_id => child.id)
    t1 = Factory.create(:tag, :site_id => parent.id)
    t2 = Factory.create(:tag, :site_id => child.id)
    t3 = Factory.create(:tag, :site_id => grandchild.id)
    
    parent.all_tags.should eql([t1, t2, t3])
    parent.all_tags_count.should eql(3)
    parent.tags_count.should eql(1)
    parent.descendant_tags.should eql([t2, t3])
    
    child.all_tags.should eql([t2, t3])
    child.all_tags_count.should eql(2)
    child.tags_count.should eql(1)
    child.descendant_tags.should eql([t3])
    
    grandchild.all_tags.should eql([t3])
    grandchild.all_tags_count.should eql(1)
    grandchild.tags_count.should eql(1)
    grandchild.descendant_tags.should be_empty
  end
  
  ### TAG READERS ###
  
  it "should hierarchically manage tag reader assignments" do
    parent = Site.create!(:name => 'Parent')
    child  = Site.create!(:name => 'Child', :parent_id => parent.id)
    grandchild = Site.create!(:name => 'Grandchild', :parent_id => child.id)
    t1 = Factory.create(:tag_reader, :site_id => parent.id)
    t2 = Factory.create(:tag_reader, :site_id => child.id)
    t3 = Factory.create(:tag_reader, :site_id => grandchild.id)
    
    parent.all_tag_readers.should eql([t1, t2, t3])
    parent.all_tag_readers_count.should eql(3)
    parent.tag_readers_count.should eql(1)
    parent.descendant_tag_readers.should eql([t2, t3])
    
    child.all_tag_readers.should eql([t2, t3])
    child.all_tag_readers_count.should eql(2)
    child.tag_readers_count.should eql(1)
    child.descendant_tag_readers.should eql([t3])
    
    grandchild.all_tag_readers.should eql([t3])
    grandchild.all_tag_readers_count.should eql(1)
    grandchild.tag_readers_count.should eql(1)
    grandchild.descendant_tag_readers.should be_empty
  end
  
  ### CATEGORIES ###
  
  it "should hierarchically manage category assignments" do
    parent = Site.create!(:name => 'Parent')
    child  = Site.create!(:name => 'Child', :parent_id => parent.id)
    grandchild = Site.create!(:name => 'Grandchild', :parent_id => child.id)
    c1 = Factory.create(:category, :site_id => parent.id)
    c2 = Factory.create(:category, :site_id => child.id)
    c3 = Factory.create(:category, :site_id => grandchild.id)
    
    parent.all_categories.should eql([c1, c2, c3])
    parent.all_categories_count.should eql(3)
    parent.categories_count.should eql(1)
    parent.descendant_categories.should eql([c2, c3])
    
    child.all_categories.should eql([c2, c3])
    child.all_categories_count.should eql(2)
    child.categories_count.should eql(1)
    child.descendant_categories.should eql([c3])
    
    grandchild.all_categories.should eql([c3])
    grandchild.all_categories_count.should eql(1)
    grandchild.categories_count.should eql(1)
    grandchild.descendant_categories.should be_empty
  end
  
  ### NOTIFICATION SPECS ###
  
  it "should hierarchically manage notification specifications assignments" do
    parent = Site.create!(:name => 'Parent')
    child  = Site.create!(:name => 'Child', :parent_id => parent.id)
    grandchild = Site.create!(:name => 'Grandchild', :parent_id => child.id)
    user = Factory.create(:user)
    ns1 = NotificationSpecification.new(:name => 'ns1')
    ns1.notification_recipients << NotificationRecipient.new(:user => user)
    parent.notification_specifications << ns1
    puts ns1.errors.full_messages
    ns2 = NotificationSpecification.new(:name => 'ns2')
    ns2.notification_recipients << NotificationRecipient.new(:user => user)
    child.notification_specifications << ns2
    ns3 = NotificationSpecification.new(:name => 'ns3')
    ns3.notification_recipients << NotificationRecipient.new(:user => user)
    grandchild.notification_specifications << ns3
    
    parent.all_notification_specifications.should eql([ns1, ns2, ns3])
    parent.all_notification_specifications_count.should eql(3)
    parent.notification_specifications_count.should eql(1)
    parent.descendant_notification_specifications.should eql([ns2, ns3])
    
    child.all_notification_specifications.should eql([ns2, ns3])
    child.all_notification_specifications_count.should eql(2)
    child.notification_specifications_count.should eql(1)
    child.descendant_notification_specifications.should eql([ns3])
    
    grandchild.all_notification_specifications.should eql([ns3])
    grandchild.all_notification_specifications_count.should eql(1)
    grandchild.notification_specifications_count.should eql(1)
    grandchild.descendant_notification_specifications.should be_empty
  end
  
  ### INVENTORY ASSETS ###
  
  it "should hierarchically manage inventory assignments" do
    parent = Site.create!(:name => 'Parent')
    child  = Site.create!(:name => 'Child', :parent_id => parent.id)
    grandchild = Site.create!(:name => 'Grandchild', :parent_id => child.id)
    a1 = Factory.create(:inventory_asset, :site_id => parent.id)
    a2 = Factory.create(:inventory_asset, :site_id => child.id)
    a3 = Factory.create(:inventory_asset, :site_id => grandchild.id)
    
    parent.all_inventory_assets.should eql([a1, a2, a3])
    parent.all_inventory_assets_count.should eql(3)
    parent.inventory_assets_count.should eql(1)
    parent.descendant_inventory_assets.should eql([a2, a3])
    
    child.all_inventory_assets.should eql([a2, a3])
    child.all_inventory_assets_count.should eql(2)
    child.inventory_assets_count.should eql(1)
    child.descendant_inventory_assets.should eql([a3])
    
    grandchild.all_inventory_assets.should eql([a3])
    grandchild.all_inventory_assets_count.should eql(1)
    grandchild.inventory_assets_count.should eql(1)
    grandchild.descendant_inventory_assets.should be_empty
  end

end