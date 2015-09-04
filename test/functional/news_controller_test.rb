# This file is part of Wiki UFC.
# Copyright (C) 2007-2015 by Álinson Xavier <isoron@gmail.com>
# Copyright (C) 2007-2008 by Adriano Freitas <adrianoblue@gmail.com>
# Copyright (C) 2007-2008 by André Castro <aisushin@gmail.com>
# Copyright (C) 2007-2008 by Rafael Barbosa <86.rafael@gmail.com>
# Copyright (C) 2007-2008 by Henrique Bustamante <bustamante.rique@gmail.com>
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

require File.dirname(__FILE__) + '/../test_helper'
require 'news_controller'

# Re-raise errors caught by the controller.
class NewsController; def rescue_action(e) raise e end; end

class NewsControllerTest < ActionController::TestCase
	def setup
		@controller = NewsController.new
		@request = ActionController::TestRequest.new
		@response = ActionController::TestResponse.new

		@course = Course.find(:first)
		@news = @course.news.find(:first)
	end

	# REST - usuários autenticados
	#context "A user" do
	#	setup { login_as :bob }
	#	should_be_restful do |resource|
	#		resource.klass = News
	#		resource.object = 'news'
	#		resource.parent = [ :course ]
	#		resource.create.params = { :title => 'test', :body => 'test', :receiver_id => 1 }
	#		resource.update.params = { :title => 'test', :body => 'test', :receiver_id => 1 }
	#		resource.destroy.redirect = "course_news_url(@course)"
	#	end
	#end

	## REST - usuários quaisquer
	#context "A stranger" do
	#	setup { logout }
	#	should_be_restful do |resource|
	#		resource.klass = News
	#		resource.object = 'news'
	#		resource.parent = [ :course ]
	#		resource.create.params = { :title => 'test', :body => 'test', :receiver_id => 1 }
	#		resource.update.params = { :title => 'test', :body => 'test', :receiver_id => 1 }
	#		resource.denied.actions = [ :new, :edit, :create, :update, :destroy ]
	#		resource.denied.redirect = "'/login'"
	#		resource.denied.flash = /must be logged in/i
	#	end
	#end

	#def test_should_accept_rss_on_index
	#	get :index, :format => 'rss', :course_id => 1
	#	assert_formatted_response :rss
	#end
end
