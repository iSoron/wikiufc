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

ActionController::Routing::Routes.draw do |map|

	# Resources
	map.resources :users
	map.resources(:courses,
		:member => {
			:enroll => :get,
			:unenroll => :get
		}
	) do |course|

		course.resources :events,
			:member => {
				:undelete => :post
			}

		course.resources :news,
			:member => {
				:undelete => :post
			}
		
		course.resources :wiki,
			:member => {
				:diff => :get,
				:versions => :get,
				:move_up => :get,
				:move_down => :get,
				:undelete => :post
			}

		course.resources :attachments,
			:member => {
				:download => :get,
				:undelete => :post
			}
	end

	# Log
	map.with_options :controller => 'log' do |log|
		log.course_log 'courses/:course_id/log', :action => 'index', :format => 'html'
		log.undo_course_log 'courses/:course_id/log/:id/undo', :action => 'undo', :format => 'html'

		log.formatted_course_log 'courses/:course_id/log.:format', :action => 'index'
	end

	# Wiki pages
	map.preview 'services/preview', :controller => 'wiki', :action => 'preview'

	# Widgets
	map.connect 'widgets/calendar/:id/:year/:month', :controller => 'events', :action => 'mini_calendar'

	# Login, logout, signup, etc
	map.with_options :controller => 'users' do |user|
		user.login    'login',    :action => 'login'
		user.logout   'logout',   :action => 'logout'
		user.signup   'signup',   :action => 'signup'
		user.settings 'settings', :action => 'settings'
   end
	
	# Pagina pessoal
	map.dashboard '/dashboard', :controller => 'users', :action => 'dashboard'

	# Stylesheets
	map.connect 'stylesheets/:action.:format', :controller => 'stylesheets'
	map.connect 'stylesheets/themes/:action.:color.:format', :controller => 'stylesheets'
	
	# Front page
	map.index '', :controller => 'courses', :action => 'index'
end
