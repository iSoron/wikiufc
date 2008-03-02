ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'redgreen'
require 'quietbacktrace'

class Test::Unit::TestCase

	self.new_backtrace_silencer :shoulda do |line| 
		line.include? 'vendor/plugins/shoulda'
	end
	self.backtrace_silencers << :shoulda

	# Transactional fixtures accelerate your tests by wrapping each test method
	# in a transaction that's rolled back on completion.  This ensures that the
	# test database remains unchanged so your fixtures don't have to be reloaded
	# between every test method.  Fewer database queries means faster tests.
	#
	# Read Mike Clark's excellent walkthrough at
	#   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
	#
	# Every Active Record database supports transactions except MyISAM tables
	# in MySQL.  Turn off transactional fixtures in this case; however, if you
	# don't care one way or the other, switching from MyISAM to InnoDB tables
	# is recommended.
	#
	# The only drawback to using transactional fixtures is when you actually 
	# need to test transactions.  Since your test is bracketed by a transaction,
	# any transactions started in your code will be automatically rolled back.
	self.use_transactional_fixtures = true

	# Instantiated fixtures are slow, but give you @david where otherwise you
	# would need people(:david).  If you don't want to migrate your existing
	# test cases which use the @david style and don't mind the speed hit (each
	# instantiated fixtures translates to a database query per test method),
	# then set this back to true.
	self.use_instantiated_fixtures  = false

	# Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
	#
	# Note: You'll currently still have to declare fixtures explicitly in integration tests
	# -- they do not yet inherit this setting
	fixtures :all

	# Add more helper methods to be used by all tests here...
	def login_as(user)
		@request.session[:user_id] = users(user).id
		@request.env["HTTP_AUTHORIZATION"] = user ? "Basic #{Base64.encode64("#{users(user).login}:test")}" : nil
	end

	def logout
		@request.session[:user_id] = nil
		@request.env["HTTP_AUTHORIZATION"] = nil
	end

    def assert_formatted_response(type, element=nil)
		assert_response :success
		snippet = "Body: #{@response.body.first(100).chomp}..."
		case type
			when :rss
		    	assert_equal Mime::RSS, @response.content_type, snippet
				assert_select "channel", 1, snippet
			when :ics
		    	assert_equal Mime::ICS, @response.content_type, snippet
			when :text
		    	assert_equal Mime::TEXT, @response.content_type, snippet
			when :xml
				assert_select element.to_s.dasherize, 1, snippet
		end
    end
end
