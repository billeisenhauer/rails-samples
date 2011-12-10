require 'spec_helper'

describe MockNetworkUser do

  it "should return a network entry given a username" do
    network_entry = MockNetworkUser.find('eisenb')
    network_entry['mail'].should eql('eisenb@slb.com')
    network_entry['displayName'].should eql('eisenb')
  end

  it "should always authenticate" do
    network_entry = MockNetworkUser.find('eisenb')
    MockNetworkUser.authenticate(network_entry, 'password').should be_true
  end

end