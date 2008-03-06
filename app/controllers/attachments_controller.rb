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

class AttachmentsController < ApplicationController

	#verify :method => :post, :only => [ :destroy, :create, :update ],
	#	:redirect_to => { :controller => 'courses', :action => :show }

	before_filter :find_attachment, :except => [ :undelete ]
	#after_filter :cache_sweep, :only => [ :create, :update, :destroy ]
	
	def show
	end

	def new
	end

	def create
		@attachment.course_id = @course.id
		@attachment.description = params[:attachment][:description]
		unless params[:attachment][:file].kind_of?(String)
			@attachment.file = params[:attachment][:file]
			@attachment.file_name = params[:attachment][:file].original_filename
			@attachment.content_type = params[:attachment][:file].content_type
		end

		# Verifica se o arquivo ja esta associado a outro anexo
		#file_path = "#{RAILS_ROOT}/public/upload/#{@course.id}/#{@attachment.file_name}"
		#@attachment.errors.add("file", "already exists") if File.exists?(file_path)

		if @attachment.save
			AttachmentCreateLogEntry.create!(:target_id => @attachment.id, :user => @current_user, :course => @course)
			flash[:notice] = 'Attachment created'[]
			redirect_to :action => 'show', :id => @attachment.id
		else
			render :action => 'new'
		end
	end

	def edit
	end

	def update
		@attachment.description = params[:attachment][:description]
		unless params[:attachment][:file].kind_of?(String)
			@attachment.file = params[:attachment][:file]
			@attachment.file_name = params[:attachment][:file].original_filename
			@attachment.content_type = params[:attachment][:file].content_type
		end

		if @attachment.save
			AttachmentEditLogEntry.create!(:target_id => @attachment.id, :user => @current_user, :course => @course)
			@attachment.last_modified = Time.now.utc
			flash[:notice] = 'Attachment updated'[]
			redirect_to :action => 'show', :id => @attachment.id
		else
			render :action => 'edit'
		end
	end

	def destroy
		@attachment.destroy
		flash[:notice] = 'Attachment removed'[]
		flash[:undo] = undelete_course_attachment_url(@course, @attachment)
		AttachmentDeleteLogEntry.create!(:target_id => @attachment.id, :user => @current_user, :course => @course)
		redirect_to :controller => 'courses', :action => 'show', :id => @course
	end

	def download
		send_file("#{RAILS_ROOT}/public/upload/#{@course.id}/#{@attachment.id}",
				:filename    =>  @attachment.file_name,
				:type        =>  @attachment.content_type,
				:disposition =>  'attachment',
				:streaming   =>  'true')
	end

	def undelete
		@attachment = Attachment.find_with_deleted(params[:id])
		@attachment.update_attribute(:deleted_at, nil)
		flash[:notice] = 'Attachment restored'[]
		AttachmentRestoreLogEntry.create!(:target_id => @attachment.id, :user => @current_user, :course => @course)
		redirect_to course_attachment_url(@attachment.course, @attachment)
	end

	protected
	def find_attachment
		params[:course_id] = Course.find_by_short_name(params[:course_id]).id if !params[:course_id].is_numeric? and !Course.find_by_short_name(params[:course_id]).nil?
		@course = Course.find(params[:course_id])
		@attachment = params[:id] ? @course.attachments.find(params[:id]) : Attachment.new
	end

	def cache_sweep
		expire_fragment(course_path(@course.id))
	end
end
