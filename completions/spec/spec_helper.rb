# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'
require 'authlogic/test_case'

# Use webrat's matchers
# require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|

  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  def current_user(stubs = {})
    @current_user ||= mock_model(User, stubs)
  end

  def user_session(stubs = {}, user_stubs = {})
    user = current_user(user_stubs)
    @current_user_session ||= mock_model(UserSession, {:user => user, :record => user}.merge(stubs))
  end

  def login(session_stubs = {}, user_stubs = {})
    UserSession.stub!(:find).and_return(user_session(session_stubs, user_stubs))
  end

  def logout
    @user_session = nil
  end
  
  # NOTE: Adding hack to enable InventoryAsset (and other) specs to run where 
  #       the acts_as_audited plugin is inserting a call to the controller
  #       to get the current user.
  #
  class AuditSweeper
    def current_user
      Factory.create(:user)
    end
  end
  
end
