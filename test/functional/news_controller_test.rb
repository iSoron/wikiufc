require File.dirname(__FILE__) + '/../test_helper'
require 'news_controller'

# Re-raise errors caught by the controller.
class NewsController; def rescue_action(e) raise e end; end

class NewsControllerTest < Test::Unit::TestCase
	def setup
		@controller = NewsController.new
		@request = ActionController::TestRequest.new
		@response = ActionController::TestResponse.new

		@course = Course.find(:first)
		@news = @course.news.find(:first)
	end

	# REST - usuários autenticados
	context "A user" do
		setup { login_as :bob }
		should_be_restful do |resource|
			resource.klass = News
			resource.object = 'news'
			resource.parent = [ :course ]
			resource.create.params = { :title => 'test', :body => 'test', :receiver_id => 1 }
			resource.update.params = { :title => 'test', :body => 'test', :receiver_id => 1 }
			resource.destroy.redirect = "course_news_index_url(@course)"
		end
	end

	# REST - usuários quaisquer
	context "A stranger" do
		setup { logout }
		should_be_restful do |resource|
			resource.klass = News
			resource.object = 'news'
			resource.parent = [ :course ]
			resource.create.params = { :title => 'test', :body => 'test', :receiver_id => 1 }
			resource.update.params = { :title => 'test', :body => 'test', :receiver_id => 1 }
			resource.denied.actions = [ :new, :edit, :create, :update, :destroy ]
			resource.denied.redirect = "'/login'"
			resource.denied.flash = /must be logged in/i
		end
	end

	def test_should_accept_rss_on_index
		get :index, :format => 'rss', :course_id => 1
		assert_formatted_response :rss
	end
end
