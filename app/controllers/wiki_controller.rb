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


class WikiController < ApplicationController

	#verify :params => :text, :only => :preview, :redirect_to => { :action => :show }
	#verify :params => [:from, :to], :only => :diff, :redirect_to => { :action => :versions }

	#after_filter :cache_sweep, :only => [ :create, :update, :destroy, :move_up,
	#		:move_down, :undelete ]

	before_filter :find_wiki, :except => [ :preview ]
	before_filter :require_login, :only => [ :new, :create, :edit, :update, :destroy,
			:move_up, :move_down ]

	def index
		respond_to do |format|
			format.html
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
		flash[:notice] = t(:wiki_page_created)

		WikiCreateLogEntry.create!(:target_id => @wiki_page.id, :user => @current_user, :course => @course)

		respond_to do |format|
			format.html { redirect_to course_wiki_instance_url(@course, @wiki_page) }
			format.xml { head :created, :location => course_wiki_instance_url(@course, @wiki_page, :format => :xml) }
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
		changed = @wiki_page.changed?

		if changed
			@wiki_page.save!
			WikiEditLogEntry.create!(:target_id => @wiki_page.id, :user => @current_user, :course => @course, :version => @wiki_page.version)
			flash[:notice] = t(:wiki_page_updated)
		end

		respond_to do |format|
			format.html { redirect_to course_wiki_instance_url(@course, @wiki_page) }
			format.xml { head :created, :location => course_wiki_instance_url(@course, @wiki_page, :format => :xml) }
		end
	end

	def destroy
        @wiki_page.remove_from_list
		@wiki_page.destroy
		flash[:notice] = t(:wiki_page_removed)

		log = WikiDeleteLogEntry.create!(:target_id => @wiki_page.id, :user => @current_user, :course => @course)
		flash[:undo] = undo_course_log_url(@course, log)

		respond_to do |format|
			format.html { redirect_to course_url(@course) }
			format.xml { head :ok }
		end
	end

	def versions
		@history_to = params[:to] || @wiki_page.versions[-1].version
		@history_from = params[:from] || (@wiki_page.versions.count > 1 ? @wiki_page.versions[-2].version : @history_to)
		@offset = params[:offset] || 0

		respond_to do |format|
			format.html
			format.xml
		end
	end

	def preview
		@text = params[:text]
		begin
			render :text => @text.format_wiki
		rescue RuntimeError
			render :text => $!.to_s.gsub(">", "&gt;").gsub("<", "&lt;"), :status => :bad_request
		end
	end

	def diff
		@wiki_page = WikiPage.find(params[:id])
        @to = @wiki_page.versions.find_by_version(params[:to])
        @from = @wiki_page.versions.find_by_version(params[:from])
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

	protected
	def find_wiki
		params[:course_id] = Course.find(:first, :conditions => ['short_name = ?', params[:course_id]], :order => 'period desc').id if !params[:course_id].is_numeric? and !Course.find_by_short_name(params[:course_id]).nil?
		@course = Course.find(params[:course_id])

		params[:id] = @course.wiki_pages.find_by_canonical_title(params[:id].pretty_url).id if params[:id] and !params[:id].is_numeric? and !@course.wiki_pages.find_by_canonical_title(params[:id].pretty_url).nil?
		@wiki_page = params[:id] ? @course.wiki_pages.find(params[:id]) : WikiPage.new(params[:wiki_page])
	end

	def cache_sweep
		expire_fragment course_url(@course.id)
		expire_fragment course_wiki_instance_url(@course.id, @wiki_page.id)
	end
end
