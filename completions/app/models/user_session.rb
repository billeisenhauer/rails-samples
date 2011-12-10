class UserSession < Authlogic::Session::Base

  ### AUTHLOGIC CONFIGURATION ###

  find_by_login_method   :find_or_create_from_network
  verify_password_method :valid_network_credentials?
  logout_on_timeout true
  
end