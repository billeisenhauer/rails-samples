module MockNetworkUser
  
  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end
  
  module ClassMethods
  
    def find(*args)
      username = args.first
      return nil unless username
      return nil if username =~ /unknown/
      MockNetworkEntry.new
    end

    def table_name
      'ou=people,dc=slb,dc=com'
    end
  
  end
  
end