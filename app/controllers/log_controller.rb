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

class LogController < ApplicationController

	before_filter :require_login, :only => [ :undo ]

	def index
		if @course
			@log_entries = @course.log_entries.paginate(:page => params[:page], :per_page => 30, :order => "created_at desc")
		else
			@log_entries = LogEntry.paginate(:page => params[:page], :per_page => 30,
				:conditions => [ "course_id not in (select id from courses where hidden = ?)", true],
				:order => "created_at desc")
		end

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
			format.html do
				redirect_to course_event_url(@log_entry.course, @log_entry.target_id) if @log_entry.kind_of?(EventDeleteLogEntry)
				redirect_to course_attachment_url(@log_entry.course, @log_entry.target_id) if @log_entry.kind_of?(AttachmentDeleteLogEntry)
				redirect_to course_news_instance_url(@log_entry.course, @log_entry.target_id) if @log_entry.kind_of?(NewsDeleteLogEntry)
				redirect_to course_wiki_instance_url(@log_entry.course, @log_entry.target_id) if @log_entry.kind_of?(WikiDeleteLogEntry)
            end
		end
	end

	protected
	def find_course
		unless params[:course_id].nil?
			params[:course_id] = Course.find(:first, :conditions => ['short_name = ?', params[:course_id]], :order => 'period desc').id if !params[:course_id].is_numeric? and !Course.find_by_short_name(params[:course_id]).nil?
			@course = Course.find(params[:course_id])
		end
	end
end
