# Wiki UFC
# Copyright (C) 2007, Adriano, Alinson, Andre, Rafael e Bustamante
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require File.dirname(__FILE__) + '/../test_helper.rb'
require 'courses_controller'

# Re-raise errors caught by the controller.
#class CoursesController; def rescue_action(e) raise e end; end

class CoursesControllerTest < ActionController::TestCase

	def setup
		@course = courses(:course_1)
		@old_course = courses(:old_course)
		LogEntry.delete_all
	end

	context "An anonymous user" do

		should_request_login_on_post_to(:new,       {})
		should_request_login_on_post_to(:create,    {})
		should_request_login_on_post_to(:edit,      {:id => 1})
		should_request_login_on_post_to(:update,    {:id => 1})
		should_request_login_on_post_to(:destroy,   {:id => 1})
		should_request_login_on_post_to(:enroll,    {:id => 1})
		should_request_login_on_post_to(:unenroll,  {:id => 1})

		context "on get to :index" do
			setup { get :index }

			should respond_with :success
			should render_template 'index'

			should "display the course list" do
				assert_select 'h1', "Disciplinas #{App.current_period}"
				assert_select 'a[href=?]', course_url(@course)
			end

			should "choose display the selected period" do
				get :index, :period => "1970.1"
				assert_select 'h1', "Disciplinas 1970.1"
			end
		end

		context "on get to :show" do
			setup { get :show, :id => @course.id }

			should respond_with :success
			should render_template 'show'

			should "display the course" do
				assert_select 'a[href=?]', course_log_url(@course)
				assert_select 'a[href=?]', course_news_url(@course)
				assert_select 'a[href=?]', course_events_url(@course)
				assert_select 'a[href=?]', new_course_event_url(@course)
				assert_select 'a[href=?]', new_course_attachment_url(@course)
				assert_select 'a[href=?]', new_course_wiki_instance_url(@course)
			end
		end
	end

	context "An authenticated user" do
		setup { login_as :bob }
	end

	# REST - usuários autenticados
	#context "A user" do
	#	#setup { login_as :bob }
	#	should_be_restful do |resource|
	#		resource.create.params = { :short_name => 'test', :full_name => 'test', :description => 'test' }
	#		resource.update.params = { :short_name => 'test', :full_name => 'test', :description => 'test' }
	#	end
	#end

	## REST - usuários quaisquer
	#context "A stranger" do
	#	setup { logout }
	#	should_be_restful do |resource|
	#		resource.create.params = { :short_name => 'test', :full_name => 'test', :description => 'test' }
	#		resource.update.params = { :short_name => 'test', :full_name => 'test', :description => 'test' }
	#		resource.denied.actions = [ :new, :edit, :create, :update, :destroy ]
	#		resource.denied.redirect = "'/login'"
	#		resource.denied.flash = /must be logged in/i
	#	end
	#end

end
