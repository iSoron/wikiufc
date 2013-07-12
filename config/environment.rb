# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.18' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.to_prepare do
    load "#{RAILS_ROOT}/app/models/message.rb"
    load "#{RAILS_ROOT}/app/models/log_entry.rb"
  end

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :key    => '_wikiufc_session_id',
    :secret => '9194c999d4c15148e1fe79e5afe2b77f9f0878f8f8391b72ff62d2ee7243d21d809096b5171be863f56701aa21efbc487d725b3660e86d0022968c19797f6f75'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc

  config.action_view.sanitized_allowed_tags = %W(p h1 h2 h3 h4 h5 h6 dl dt ol
  ul li address blockquote del div hr ins pre a abbr acronym dfn em strong
  code samp kbd var b i big small tt span br bdo  cite del ins q sub sup
  img map table tr td th colgroup col caption thead tbody tfoot)

  config.action_view.sanitized_allowed_attributes = %W(align alt border
  cellpadding cellspacing cols colspan coords height href longdesc name
  noresize nowrap rel rows rowspan rules scope shape size span src start
  style summary title type usemap valign width)

  config.time_zone = 'America/Fortaleza'

  config.gem "bluecloth"
  config.gem "haml"
  config.gem "hpricot"
  config.gem "icalendar"
  config.gem 'thoughtbot-shoulda', :lib => 'shoulda/rails', :source => "http://gems.github.com"
end
