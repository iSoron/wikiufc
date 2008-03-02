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
require 'events_controller'

# Re-raise errors caught by the controller.
class EventsController; def rescue_action(e) raise e end; end

class EventsControllerTest < Test::Unit::TestCase

	def setup
		@controller = EventsController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
		@course = Course.find(:first)
		@event = @course.events.find(:first)
	end

	# REST - usuários autenticados
	context "A user" do
		setup { login_as :bob }
		should_be_restful do |resource|
			resource.parent = [ :course ]
			resource.create.params = { :title => 'test', :date => Date.today, :time => Time.now, :description => 'test', :created_by => 1 }
			resource.update.params = { :title => 'test', :date => Date.today, :time => Time.now, :description => 'test', :created_by => 1 }

		end
	end

	# REST - usuários quaisquer
	context "A stranger" do
		setup { logout }
		should_be_restful do |resource|
			resource.parent = [ :course ]
			resource.create.params = { :title => 'test', :date => Date.today, :time => Time.now, :description => 'test', :created_by => 1 }
			resource.update.params = { :title => 'test', :date => Date.today, :time => Time.now, :description => 'test', :created_by => 1 }
			resource.denied.actions = [ :new, :edit, :create, :update, :destroy ]
			resource.denied.redirect = "'/login'"
			resource.denied.flash = /must be logged in/i
		end
	end

	def test_should_accept_icalendar_on_index
		get :index, :format => 'ics', :course_id => 1
		assert_formatted_response :ics
	end
end
