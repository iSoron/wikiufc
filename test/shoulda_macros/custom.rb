class Test::Unit::TestCase
	def self.should_request_login_on_post_to(action, params)
		should "request login on post to #{action}" do
			post action, params
			assert_redirected_to login_url
		end
	end

	def self.should_create_log_entry(&block)
		should "create log entry" do
			log_entry_class, target_id, user_id = instance_eval(&block)
			assert log_entry_class.find(:first, :conditions => { :user_id => user_id, :target_id => target_id })
		end
	end
end
