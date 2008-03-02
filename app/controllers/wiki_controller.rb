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

class WikiController < ApplicationController

	verify :params => :text, :only => :preview, :redirect_to => { :action => :show }
	verify :params => [:from, :to], :only => :diff, :redirect_to => { :action => :versions }

	after_filter :cache_sweep, :only => [ :create, :update, :destroy ]
	before_filter :find_wiki, :except => [ :preview, :undelete ]
	before_filter :require_login, :only => [ :new, :create, :edit, :update, :destroy,
			:move_up, :move_down, :undelete ]

	def index
		@wiki_pages = @course.wiki_pages

		respond_to do |format|
			format.html { redirect_to course_url(@course) }
			format.xml { render :xml => @wiki_pages }
		end
	end

	def new
	end

	def create
		@wiki_page.version = 1
		@wiki_page.user_id = session[:user_id]
		@wiki_page.course_id = @course.id
		@wiki_page.description = "Nova página"
		@wiki_page.save!
		flash[:notice] = "Wiki page created"[]

		WikiCreateLogEntry.create!(:target_id => @wiki_page.id, :user => @current_user, :course => @course)

		respond_to do |format|
			format.html { redirect_to course_wiki_path(@course, @wiki_page) }
			format.xml { head :created, :location => formatted_course_wiki_url(@course, @wiki_page, :xml) }
		end
	end

	def show
		@wiki_page.revert_to(params[:version]) if params[:version]

		respond_to do |format|
			format.html
			format.xml { render :xml => @wiki_page }
			format.text { render :text => "# #{@wiki_page.title}\n\n#{@wiki_page.content}" }
		end
	end

	def edit
		@wiki_page.revert_to(params[:version]) if params[:version]
		@wiki_page.description = params[:description] || ""
	end

	def update
		@wiki_page.attributes = params[:wiki_page]
		@wiki_page.user_id = session[:user_id]
		@wiki_page.course_id = @course.id
		dirty = @wiki_page.dirty?
		@wiki_page.save!

		WikiEditLogEntry.create!(:target_id => @wiki_page.id, :user => @current_user, :course => @course, :version => @wiki_page.version) if dirty

		flash[:notice] = "Wiki page updated"[]

		respond_to do |format|
			format.html { redirect_to course_wiki_path(@course, @wiki_page) }
			format.xml { head :created, :location => formatted_course_wiki_url(@course, @wiki_page, :xml) }
		end
	end

	def destroy
		@wiki_page.destroy
		flash[:notice] = "Wiki page removed"[]
		flash[:undo] = url_for(:course_id => @course, :id => @wiki_page.id, :action => 'undelete')

		WikiDeleteLogEntry.create!(:target_id => @wiki_page.id, :user => @current_user, :course => @course)

		respond_to do |format|
			format.html { redirect_to course_url(@course) }
			format.xml { head :ok }
		end
	end

	def versions
		@history_to = params[:to] || @wiki_page.versions.count
		@history_from = params[:from] || @wiki_page.versions.count - 1
		@offset = params[:offset] || 0

		respond_to do |format|
			format.html
			format.xml
		end
	end

	def preview
		@text = params[:text]
		render :text => BlueCloth.new(@text).to_html
	end

	def diff
		@to = WikiPage.find_version(params[:id], params[:to])
		@from = WikiPage.find_version(params[:id], params[:from])
		@diff = WikiPage.diff(@from, @to)
	end

	def move_up
		@wiki_page.move_higher
		@wiki_page.save
		flash[:highlight] = @wiki_page.id

		respond_to do |format|
			format.html { redirect_to course_url(@course) }
		end
	end

	def move_down
		@wiki_page.move_lower
		@wiki_page.save
		flash[:highlight] = @wiki_page.id

		respond_to do |format|
			format.html { redirect_to course_url(@course) }
		end
	end

	def undelete
		@wiki_page = WikiPage.find_with_deleted(params[:id])
		@wiki_page.update_attribute(:deleted_at, nil)
		flash[:notice] = "Wiki page restored"[]

		WikiRestoreLogEntry.create!(:target_id => @wiki_page.id, :user => @current_user, :course => @wiki_page.course)

		respond_to do |format|
			format.html { redirect_to course_wiki_url(@wiki_page.course, @wiki_page) }
		end
	end

	protected
	def find_wiki
		params[:course_id] = Course.find_by_short_name(params[:course_id]).id if !params[:course_id].is_numeric? and !Course.find_by_short_name(params[:course_id]).nil?
		@course = Course.find(params[:course_id])

		params[:id] = @course.wiki_pages.find_by_title(params[:id]).id if params[:id] and !params[:id].is_numeric? and !@course.wiki_pages.find_by_title(params[:id]).nil?
		@wiki_page = params[:id] ? @course.wiki_pages.find(params[:id]) : WikiPage.new(params[:wiki_page])
	end

	def cache_sweep
		expire_fragment(:controller => 'courses', :action => 'show')
		expire_fragment(:action => 'show')
	end
end
