# -*- encoding : utf-8 -*-
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

class AttachmentsController < ApplicationController

	#verify :method => :post, :only => [ :destroy, :create, :update ],
	#	:redirect_to => { :controller => 'courses', :action => :show }

	#after_filter :cache_sweep, :only => [ :create, :update, :destroy ]

	before_filter :find_attachment
	
	def show
		respond_to do |format|
			format.html
			format.xml { render :xml => @attachment }
		end
	end

	def new
	end

	def create
		@attachment.course_id = @course.id
		@attachment.path = params[:attachment][:path]
		@attachment.front_page = params[:attachment][:front_page]
		@attachment.description = params[:attachment][:description]
		@attachment.file_name = "blank"
		unless params[:attachment][:file].nil?
			@attachment.file = params[:attachment][:file]
			@attachment.file_name = params[:attachment][:file].original_filename
			@attachment.content_type = params[:attachment][:file].content_type
		end
		@attachment.save!

		AttachmentCreateLogEntry.create!(:target_id => @attachment.id, :user => @current_user, :course => @course)
		flash[:notice] = t(:attachment_created)

		respond_to do |format|
			format.html { redirect_to course_attachment_url(@course, @attachment) }
			format.xml { head :created, :location => course_attachment_url(@course, @attachment, :format => :xml) }
		end
	end

	def edit
	end

	def update
		@attachment.path = params[:attachment][:path]
		@attachment.front_page = params[:attachment][:front_page]
		@attachment.description = params[:attachment][:description]
		unless params[:attachment][:file].nil?
			@attachment.file = params[:attachment][:file]
			@attachment.file_name = params[:attachment][:file].original_filename
			@attachment.content_type = params[:attachment][:file].content_type
		end
		changed = @attachment.changed?

		if changed
			@attachment.last_modified = Time.now.utc
			@attachment.save!
			AttachmentEditLogEntry.create!(:target_id => @attachment.id, :user => @current_user, :course => @course)
			flash[:notice] = t(:attachment_updated)
		end

		respond_to do |format|
			format.html { redirect_to course_attachment_url(@course, @attachment) }
			format.xml { head :created, :location => course_attachment_url(@course, @attachment, :format => :xml) }
		end
	end

	def destroy
		@attachment.destroy
		flash[:notice] = t(:attachment_removed)

		log = AttachmentDeleteLogEntry.create!(:target_id => @attachment.id, :user => @current_user, :course => @course)
		flash[:undo] = undo_course_log_url(@course, log)
		
		respond_to do |format|
			format.html { redirect_to course_url(@course) }
			format.xml { head :ok }
		end
	end

	def download

		send_file("#{Rails.root}/public/upload/#{@course.id}/#{@attachment.id}",
				:filename    =>  @attachment.file_name,
				:type        =>  @attachment.content_type,
				:disposition =>  'inline',
				:streaming   =>  'true')
	end

	protected
	def find_attachment
		params[:course_id] = Course.find(:first, :conditions => ['short_name = ?', params[:course_id]], :order => 'period desc').id if !params[:course_id].is_numeric? and !Course.find_by_short_name(params[:course_id]).nil?
		@course = Course.find(params[:course_id])
		@attachment = params[:id] ? @course.attachments.find(params[:id]) : Attachment.new
	end

	def cache_sweep
		expire_fragment(course_path(@course.id))
	end
end
