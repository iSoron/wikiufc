# -*- encoding : utf-8 -*-
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

class EventsController < ApplicationController

	before_filter :find_event, :except => [ :mini_calendar ]
	#after_filter :cache_sweep, :only => [ :create, :update, :destroy ]

	def index
		@events = @course.events

		respond_to do |format|
			format.html
			format.xml { render :xml => @events }
			format.ics { response.content_type = Mime::ICS; render :text => Event.to_ical([@course]) }
		end
	end

	def show
		@event.revert_to(params[:version]) if params[:version]
		respond_to do |format|
			format.html
			format.xml { render :xml => @event }
		end
	end

	def new
		@event.time = Time.now
	end

	def create
		@event.course_id = @course.id
		@event.created_by = session[:user_id]
		@event.save!
		flash[:notice] = t(:event_created)

		EventCreateLogEntry.create!(:target_id => @event.id, :user => @current_user, :course => @course, :version => @event.version)

		respond_to do |format|
			format.html { redirect_to course_event_path(@course, @event) }
			format.xml { head :created, :location => course_event_url(@course, @event, :format => :xml) }
		end
	end

	def edit
		@event.revert_to(params[:version]) if params[:version]
	end

	def update
		@event.attributes = params[:event]
		dirty = @event.changed?
		@event.save!
		flash[:notice] = t(:event_updated)

		EventEditLogEntry.create!(:target_id => @event.id, :user => @current_user, :course => @course, :version => @event.version) if dirty

		respond_to do |format|
			format.html { redirect_to course_event_path(@course, @event) }
			format.xml { head :created, :location => course_event_url(@course, @event, :format => :xml) }
		end
	end

	def destroy
		@event.destroy
		flash[:notice] = t(:event_removed)

		log = EventDeleteLogEntry.create!(:target_id => @event.id, :user => @current_user, :course => @course, :version => @event.version)
		flash[:undo] = undo_course_log_url(@course, log)

		respond_to do |format|
			format.html { redirect_to course_events_path(@course) }
			format.xml { head :ok }
		end
	end

	# Exibe o widget do calendario
	def mini_calendar
		@course = Course.find(params[:id])
		@year = params[:year].to_i
		@month = params[:month].to_i

		@ajax = true
		@events = @course.events

		render :template => 'widgets/calendario', :layout => false
	end

	protected
	def find_event
		params[:course_id] = Course.find(:first, :conditions => ['short_name = ?', params[:course_id]], :order => 'period desc').id if !params[:course_id].is_numeric? and !Course.find_by_short_name(params[:course_id]).nil?
		@course = Course.find(params[:course_id])
		@event = params[:id] ? @course.events.find(params[:id]) : Event.new(params[:event])
	end

	def cache_sweep
		expire_fragment(course_path(@course.id, :part => 'right'))
		expire_fragment(course_events_path(@course.id))
	end
end
