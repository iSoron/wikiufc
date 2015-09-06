require 'simplecov'
SimpleCov.start

require 'turn/colorize'
module Turn
  module Colorize
    def self.color_supported?
      true
    end
  end
end

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def login_as(user)
    @user = users(user)
    @request.session[:user_id] = @user.id
    @request.env["HTTP_AUTHORIZATION"] = user ? "Basic #{Base64.encode64("#{@user.login}:test")}" : nil
  end

  def logout
    @request.session[:user_id] = nil
    @request.env["HTTP_AUTHORIZATION"] = nil
  end

  def assert_formatted_response(type, element = nil)
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
    else
      fail ArgumentError
    end
  end
end

class Test::Unit::TestCase
  def self.should_request_login_on_post_to(action, params = {})
    should "request login on post to #{action}" do
      post action, params
      assert_redirected_to login_url
    end
  end

  def self.should_have_access_denied_on_post_to(action, params = {})
    should "have access denied on post to #{action}" do
      post action, params
      assert_response 401
    end
  end

  def self.should_create_log_entry(&block)
    should "create log entry" do
      log_entry_class, target_id, user_id = instance_eval(&block)
      assert log_entry_class.find(:first, conditions: { user_id: user_id,
                                                        target_id: target_id })
    end
  end
end
