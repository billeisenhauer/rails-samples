class MockNetworkUser
  
  def self.find(username)
    { 'mail' => "#{username}@slb.com", 'displayName' => username }
  end
  
  def self.authenticate(network_entry, password_plaintext)
    true
  end
  
end