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

class LogController < ApplicationController

	before_filter :find_course

	def index
		@log_entries = @course.log_entries.find(:all, :limit => 50) #.paginate(:page => params[:page], :per_page => 30)
		respond_to do |format|
			format.html
			format.rss { response.content_type = Mime::RSS }
			format.xml { render :xml => @log_entries }
		end
	end

	def undo
		@log_entry = LogEntry.find(params[:id])
		@log_entry.undo!(@current_user)

		respond_to do |format|
			format.html { redirect_to course_log_url }
		end
	end

	protected
	def find_course
		params[:course_id] = Course.find_by_short_name(params[:course_id]).id if !params[:course_id].is_numeric? and !Course.find_by_short_name(params[:course_id]).nil?
		@course = Course.find(params[:course_id])
	end
end
