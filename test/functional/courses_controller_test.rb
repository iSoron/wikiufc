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
		context "on get to :index" do
			setup { get :index }

			should_respond_with :success
			should_render_template 'index'

			should "display the course list" do
				assert_select 'a[href=?]', course_url(@course)
			end
		end
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
