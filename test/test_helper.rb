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
end

class Test::Unit::TestCase
  def self.should_request_login_on_post_to(action, params)
    should "request login on post to #{action}" do
      post action, params
      assert_redirected_to login_url
    end
  end

  def self.should_have_access_denied_on_post_to(action, params)
    should "have access denied on post to #{action}" do
      assert_raises AccessDenied do
        post action, params
      end
    end
  end

  def self.should_create_log_entry(&block)
    should "create log entry" do
      log_entry_class, target_id, user_id = instance_eval(&block)
      assert log_entry_class.find(:first, :conditions => { :user_id => user_id, :target_id => target_id })
    end
  end
end
