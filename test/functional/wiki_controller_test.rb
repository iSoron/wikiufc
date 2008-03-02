
# Engenharia de Software 2007.1
# Copyright (C) 2007, Adriano, Alinson, Andre, Rafael e Bustamante
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

require File.dirname(__FILE__) + '/../test_helper'
require 'wiki_controller'

# Re-raise errors caught by the controller.
class WikiController; def rescue_action(e) raise e end; end

class WikiControllerTest < Test::Unit::TestCase
	def setup
		@controller = WikiController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
		@course = Course.find(:first)
		@wiki_page = @course.wiki_pages.create(:title => 'test1', :content => 'test1', :description => 'test', :version => 1)
		@wiki_page.user = users(:bob)
		@wiki_page.save!
	end

	# REST - usuários autenticados
	context "A user" do
		setup { login_as :bob }
		should_be_restful do |resource|
			resource.klass = WikiPage
			resource.parent = [ :course ]
			resource.create.params = { :title => 'test2', :description => 'test', :content => 'test2', :course_id => 1 }
			resource.update.params = { :title => 'test3', :description => 'test', :content => 'test3', :course_id => 1 }
			resource.actions = [ :show, :new, :edit, :update, :create, :destroy ]
			resource.destroy.redirect = "course_url(@course)"
			resource.create.redirect = "course_wiki_url(@course, @wiki_page)"
			resource.update.redirect = "course_wiki_url(@course, @wiki_page)"
		end
	end

	# REST - usuários quaisquer
	context "A stranger" do
		setup { logout }
		should_be_restful do |resource|
			resource.klass = WikiPage
			resource.parent = [ :course ]
			resource.create.params = { :title => 'test4', :description => 'test', :content => 'test4', :course_id => 1 }
			resource.update.params = { :title => 'test5', :description => 'test', :content => 'test5', :course_id => 1 }
			resource.actions = [ :show, :new, :edit, :update, :create, :destroy ]
			resource.denied.actions = [ :new, :edit, :create, :update, :destroy ]
			resource.denied.redirect = "'/login'"
			resource.denied.flash = /must be logged in/i
		end
	end

	def test_should_accept_text_on_show
		get :show, :format => 'txt', :course_id => 1, :id => @wiki_page.id
		assert_formatted_response :text
	end

	def test_should_accept_html_on_versions
		get :versions, :course_id => 1, :id => @wiki_page.id
		assert_response :success
	end

	def test_should_accept_xml_on_versions
		get :versions, :format => 'xml', :course_id => 1, :id => @wiki_page.id
		assert_formatted_response :xml, :versions
	end
end
