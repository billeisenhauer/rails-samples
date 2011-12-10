# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_suzannecan_session',
  :secret      => '9ebb9a57d77ac939c948cd23afb10a5811d20b02d53aa2d16c39554372f1aa2621d9c88c1bb669cd56f707fd3e4dc42283a26e3c30f4fa3da13d17d09e8e2ff0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
