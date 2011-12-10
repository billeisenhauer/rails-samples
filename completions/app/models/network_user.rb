require 'singleton'

class NetworkUser # < ActiveLdap::Base
  include Singleton
  
  attr_accessor :ldap
  
  def self.find(username)
    instance.find(username)
  end
  
  def self.authenticate(network_entry, password_plaintext)
    instance.authenticate(network_entry, password_plaintext)
  end
  
  def find(username)
    results = ldap.search(:base => AppConfig.ldap_base, :filter => "(alias=#{username})")
    results.first
  end

  def authenticate(network_entry, password_plaintext)
    username = network_entry["alias"]
    ldap.bind_as(:base => @base, :filter => "(alias=#{username})", :password => password_plaintext)
  end
  
  private
  
    def initialize
      @base = AppConfig.ldap_base 
      @ldap = Net::LDAP.new(:host => AppConfig.ldap_host, :port => AppConfig.ldap_port)
    end
  
end