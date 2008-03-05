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

class EventsController < ApplicationController

	before_filter :find_event, :except => [ :mini_calendar, :undelete ]
	after_filter :cache_sweep, :only => [ :create, :update, :destroy ]

	def index
		@events = @course.events

		respond_to do |format|
			format.html
			format.xml { render :xml => @events }
			format.ics { response.content_type = Mime::ICS; render :text => Event.to_ical([@course]) }
		end
	end

	def show
		respond_to do |format|
			format.html
			format.xml { render :xml => @event }
		end
	end

	def new
	end

	def create
		@event.course_id = @course.id
		@event.created_by = session[:user_id]
		@event.save!
		flash[:notice] = 'Event created'[]

		EventCreateLogEntry.create!(:target_id => @event.id, :user => @current_user, :course => @course)

		respond_to do |format|
			format.html { redirect_to course_event_path(@course, @event) }
			format.xml { head :created, :location => formatted_course_event_url(@course, @event, :xml) }
		end
	end

	def edit
	end

	def update
		@event.attributes = params[:event]
		@event.save!
		flash[:notice] = 'Event updated'[]

		EventEditLogEntry.create!(:target_id => @event.id, :user => @current_user, :course => @course)

		respond_to do |format|
			format.html { redirect_to course_event_path(@course, @event) }
			format.xml { head :created, :location => formatted_course_event_url(@course, @event, :xml) }
		end
	end

	def destroy
		@event.destroy
		flash[:notice] = 'Event removed'[]
		flash[:undo] = undelete_course_event_url(@course, @event)

		EventDeleteLogEntry.create!(:target_id => @event.id, :user => @current_user, :course => @course)

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

	def undelete
		@event = Event.find_with_deleted(params[:id])
		@event.update_attribute(:deleted_at, nil)
		flash[:notice] = "Event restored"[]

		EventRestoreLogEntry.create!(:target_id => @event.id, :user => @current_user, :course => @course)
		
		respond_to do |format|
			format.html { redirect_to course_event_url(@event.course, @event) }
		end
	end


	protected
	def find_event
		params[:course_id] = Course.find_by_short_name(params[:course_id]).id if !params[:course_id].is_numeric? and !Course.find_by_short_name(params[:course_id]).nil?
		@course = Course.find(params[:course_id])
		@event = params[:id] ? @course.events.find(params[:id]) : Event.new(params[:event])
	end

	def cache_sweep
		expire_fragment(:controller => 'courses', :action => 'show', :part => 'right')
		expire_fragment(:action => 'index')
	end
end
