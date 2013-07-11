# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wikiufc_session',
  :secret      => 'b5562c2c0918ac657089534e97f76ae0e042d350dd81aa18a0fdb8ce52df38e7ecd39cdfc3e682d2ef01fe3186c7ed2d9c8767825a876eb3e46323f26a7c346f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
