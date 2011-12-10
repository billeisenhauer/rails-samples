require 'spec_helper'

describe NetworkUser do

  it "should return a network entry given a username" do
    NetworkUser.instance.should_receive(:find).and_return({'alias' => 'eisenb'})
    network_entry = NetworkUser.find('eisenb')
    network_entry['alias'].should eql('eisenb')
  end
  
  it "should find the requested username" do
    NetworkUser.instance.ldap.should_receive(:search).and_return([{'alias' => 'eisenb'}])
    NetworkUser.instance.find('eisend').should eql({'alias' => 'eisenb'})
  end

  it "should authenticate" do
    NetworkUser.instance.ldap.should_receive(:bind_as).and_return(true)
    NetworkUser.authenticate({'alias' => 'eisenb'}, 'password').should be_true
  end

  it "should not authenticate" do
    NetworkUser.instance.ldap.should_receive(:bind_as).and_return(false)
    NetworkUser.authenticate({'alias' => 'eisenb'}, 'password').should_not be_true
  end

end