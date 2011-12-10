require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  
  before(:each) do
    @guest_role = Factory.create(:guest_role)
    @parent_site = Factory.create(:site)
    @site = @parent_site.children.create :name => 'child'
  end
  
  ### VALIDATIONS ###
  
  it "is valid with valid attributes" do
    User.new(Factory.attributes_for(:user)).should be_valid
  end
  
  it "is valid with valid attributes and default site" do
    user = Factory.create(:user)
    site = Factory.create(:site)
    user.site_memberships.create(:site => site)
    user.site = site
    user.should be_valid
  end
  
  it "is not valid without a username" do
    user = User.new(:username => nil)
    user.should_not be_valid
    user.should have(4).error_on(:username)
  end
  
  it 'is not valid with a default site to which the user is not a member' do
    user = User.new(:username => 'anything')
    user.site = Factory.create(:site)
    user.should_not be_valid
    user.should have(1).error_on(:site)
  end
  
  it 'is not valid with a non-existent site assignment to user' do
    user = User.new(:username => 'anything', :site_id => 9999)
    user.should_not be_valid
    user.should have(1).error_on(:site)
  end
  
  ### NAMED SCOPES / FINDERS ###
  
  it "should filter by site" do
    site = Factory.create(:site)
    expected_user   = Factory.create(:user)
    Factory.create(:site_membership, :site => @site, :user => expected_user)
    unexpected_user = Factory.create(:user)
    Factory.create(:site_membership, :site => site, :user => unexpected_user)
    User.for_site(@site).should eql([expected_user])
  end   
  
  it "should return all users for for_site if no site is given" do
    site = Factory.create(:site)
    a_user   = Factory.create(:user)
    Factory.create(:site_membership, :site => @site, :user => a_user)
    b_user = Factory.create(:user)
    Factory.create(:site_membership, :site => site, :user => b_user)
    User.for_site.should eql([a_user, b_user])
  end
  
  it "should return users with Guest role" do
    guest = Factory.create(:user, :role => @guest_role)
    champion = Factory.create(:champion_user)
    administrator = Factory.create(:administrator_user)
    support_administrator = Factory.create(:support_administrator_user)
    User.for_role('Guest').should eql([guest])
  end
  
  it "should return users with Champion role" do
    guest = Factory.create(:user, :role => @guest_role)
    champion = Factory.create(:champion_user)
    administrator = Factory.create(:administrator_user)
    support_administrator = Factory.create(:support_administrator_user)
    User.for_role('Champion').should eql([champion])
  end
  
  it "should return users with Administrator role" do
    guest = Factory.create(:user, :role => @guest_role)
    champion = Factory.create(:champion_user)
    administrator = Factory.create(:administrator_user)
    support_administrator = Factory.create(:support_administrator_user)
    User.for_role('Administrator').should eql([administrator])
  end
  
  it "should return users with Support Administrator role" do
    guest = Factory.create(:user, :role => @guest_role)
    champion = Factory.create(:champion_user)
    administrator = Factory.create(:administrator_user)
    support_administrator = Factory.create(:support_administrator_user)
    User.for_role('Support Administrator').should eql([support_administrator])
  end
  
  it "should return users with Support Administrator role" do
    user = Factory.create(:user)
    User.unauthorized.should eql([user])
  end
  
  ### SORTING / SEARCHING ###
  
  it "should return expected list options" do
    list_option_names = User.list_option_names
    [:sorted_by, :for_site, :for_role, :unauthorized, :search].each do |o| 
      list_option_names.should include(o) 
    end
  end
  
  it "should sort by username" do
    a_user = Factory.create(:user, :username => 'AAAAAA')
    b_user = Factory.create(:user, :username => 'BBBBBB')
    User.sorted_by('username asc').should eql([a_user, b_user])
    User.sorted_by('username desc').should eql([b_user, a_user])
  end
  
  it "should sort by role names" do
    guest = Factory.create(:user, :role => @guest_role)
    champion = Factory.create(:champion_user)
    administrator = Factory.create(:administrator_user)
    support_administrator = Factory.create(:support_administrator_user)
    User.sorted_by('role asc').should eql([administrator, champion, guest, support_administrator])
    User.sorted_by('role desc').should eql([support_administrator, guest, champion, administrator])
  end
  
  it "should search by username" do
    a_user = Factory.create(:user, :username => 'AAAAAA')
    b_user = Factory.create(:user, :username => 'BBBBBB')
    User.search('AAAAAA').should eql([a_user])   
  end
  
  it "should search by name" do
    a_user = Factory.create(:user, :name => 'AAAAAA')
    b_user = Factory.create(:user, :name => 'BBBBBB')
    User.search('BBBBBB').should eql([b_user])   
  end
  
  it "should filter for site and order by name asc" do
    site   = Factory.create(:site)
    a_user = Factory.create(:user, :name => 'A1')
    Factory.create(:site_membership, :site => @site, :user => a_user)
    b_user = Factory.create(:user, :name => 'B1')
    Factory.create(:site_membership, :site => site, :user => b_user)
    c_user = Factory.create(:user, :name => 'C1')
    Factory.create(:site_membership, :site => site, :user => c_user)
    list_options = {
      :for_site  => site,
      :sorted_by => 'name asc'
    }
    User.filter(list_options).should eql([b_user, c_user])
  end
  
  ### ROLES ###
  
  it "should have administrator role" do
    user = Factory(:administrator_user)
    user.role_name.should eql('Administrator')
    user.role_symbols.should eql([:administrator])
  end
  
  it "should have no role" do
    user = Factory.create(:user)
    user.role_name.should eql('')
  end
  
  it "should show user with Guest role as Guest" do
    user = Factory.create(:user, :role => @guest_role)
    user.guest?.should be_true
  end
  
  it "should now show user with Champion role as Guest" do
    user = Factory.create(:champion_user)
    user.guest?.should_not be_true
  end
  
  ### SITES / SITE MEMBERSHIPS ###
  
  it "should have sites" do
    user = Factory.create(:user)
    SiteMembership.create(:user => user, :site => @parent_site)
    user.sites(true).should include(@parent_site)
  end
  
  it "should have visible sites" do
    user = Factory.create(:user)
    SiteMembership.create(:user => user, :site => @parent_site)
    user.sites(true)
    user.visible_sites.should include(@parent_site)
    user.visible_sites.should include(@site)
  end
  
  it "should be able to change sites" do
    user = Factory.create(:user)
    SiteMembership.create(:user => user, :site => @parent_site)
    SiteMembership.create(:user => user, :site => @site)
    user.sites(true)
    user.can_change_sites?.should be_true
  end
  
  it "should not be able to change sites" do
    user = Factory.create(:user)
    SiteMembership.create(:user => user, :site => @site)
    user.sites(true)
    user.can_change_sites?.should_not be_true
  end
  
  ### AUTHENTICATION ###
  
  it "should return network user if exists in ldap" do
    user = Factory.create(:user, :username => 'eisenb')
    network_entry = {
      'alias' => 'eisenb'
    }
    User::NETWORK_USER_CLASS.should_receive(:find).with('eisenb').and_return(network_entry)
    user.network_user.should eql({'alias' => 'eisenb'})
  end
  
  it 'should create user for new network user' do
    network_entry = {
      'alias' => 'eisenb',
      'mail' => 'bill@slb.com',
      'displayName' => 'Bill E'
    }
    User::NETWORK_USER_CLASS.should_receive(:find).with('eisenb').and_return(network_entry)    
    user = User.create_from_network_if_valid('eisenb')
    user.username.should eql('eisenb')
    user.email.should eql('bill@slb.com')
    user.name.should eql('Bill E')
  end
  
  it 'should not create user for unknown network user' do
    User::NETWORK_USER_CLASS.should_receive(:find).with('eisenb').and_return(nil)    
    User.create_from_network_if_valid('eisenb').should be_nil
  end
  
  it 'should return new network user for find or create' do
    network_entry = {
      'alias' => 'eisenb',
      'mail' => 'bill@slb.com',
      'displayName' => 'Bill E'
    }
    User::NETWORK_USER_CLASS.should_receive(:find).with('eisenb').and_return(network_entry)
    lambda do
      User.find_or_create_from_network('eisenb')
    end.should change{ User.count }.by(1)
  end
  
  it 'should return existing user for find or create' do
    user = Factory.create(:user, :username => 'eisenb')
    lambda do
      User.find_or_create_from_network('eisenb').should eql(user)
    end.should change{ User.count }.by(0)
  end
  
  it 'should authenticate network user' do
    user = Factory.create(:user, :username => 'eisenb', :email => 'bill@slb.com', :name => 'Bill E')
    network_entry = {
      'mail' => 'eisenb@slb.com',
      'displayName' => 'eisenb'
    }
    User::NETWORK_USER_CLASS.should_receive(:authenticate).with(network_entry, 'password').and_return(network_entry)
    user.send(:valid_network_credentials?, 'password').should be_true
  end
  
  ### MISCELLANEOUS ###
  
  it 'should return username as id' do
    user = User.new(:username => 'anything')
    user.to_param.should eql("anything")
  end
  
  it 'should use the name as the display name' do
    user = User.new(:name => 'name', :email => 'bill@slb.com')
    user.display_name.should eql('name')
  end
  
  it 'should use the email as the display name' do
    user = User.new(:email => 'bill@slb.com')
    user.display_name.should eql('bill@slb.com')
  end
  
  it 'should be Unamed for display name' do
    User.new.display_name.should eql('Unamed')
  end
  
  it 'should be idenfied based upon the name' do
    user = User.new(:name => 'name', :email => 'bill@slb.com')
    user.identified?.should be_true
  end
  
  it 'should be idenfied based upon the email' do
    user = User.new(:email => 'bill@slb.com')
    user.identified?.should be_true
  end
  
  it 'should not be identified' do
    User.new.identified?.should_not be_true
  end
  
  it "should return identified users for recipient list" do
    identified_user   = Factory.create(:user)
    Factory.create(:site_membership, :site => @site, :user => identified_user)
    User.recipient_list_for(@site).should eql([identified_user])
  end

end