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

class NewsController < ApplicationController

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	#verify :method => :post, :only => [ :destroy, :create, :update ],
	#	:redirect_to => { :action => :list }

	#after_filter :cache_sweep, :only => [ :create, :update, :destroy ]

	def index
		@news = @course.news
		respond_to do |format|
			format.html
			format.xml { render :xml => @news }
			format.rss { response.content_type = Mime::RSS }
		end
	end

	def show
		@news.revert_to(params[:version]) if params[:version]
		respond_to do |format|
			format.html
			format.xml { render :xml => @news }
		end
	end

	def new
	end

	def create
		@news.receiver_id = @course.id
		@news.sender_id = session[:user_id]
		@news.timestamp = Time.now.utc
		@news.save!
		flash[:notice] = t(:news_created)

		NewsCreateLogEntry.create!(:target_id => @news.id, :user => @current_user, :course => @course, :version => @news.version)

		respond_to do |format|
			format.html { redirect_to course_news_instance_path(@course, @news) }
			format.xml { head :created, :location => course_news_instance_url(@course, @news, :format => :xml) }
		end
	end

	def edit
		@news.revert_to(params[:version]) if params[:version]
	end

	def update
		@news.attributes = params[:news]
		@news.timestamp = Time.now.utc
		dirty = @news.changed?
		@news.save!
		flash[:notice] = t(:news_updated)

		NewsEditLogEntry.create!(:target_id => @news.id, :user => @current_user, :course => @course, :version => @news.version) if dirty

		respond_to do |format|
			format.html { redirect_to course_news_instance_path(@course, @news) }
			format.xml { head :created, :location => course_news_instance_url(@course, @news, :format => :xml) }
		end
	end

	def destroy
		@news.destroy
		flash[:notice] = t(:news_removed)

		log = NewsDeleteLogEntry.create!(:target_id => @news.id, :user => @current_user, :course => @course, :version => @news.version)
		flash[:undo] = undo_course_log_url(@course, log)

		respond_to do |format|
			format.html { redirect_to course_news_path(@course) }
			format.xml { head :ok }
		end
	end

	protected
	def find_new
		params[:course_id] = Course.find(:first, :conditions => ['short_name = ?', params[:course_id]], :order => 'period desc').id if !params[:course_id].is_numeric? and !Course.find_by_short_name(params[:course_id]).nil?
		@course = Course.find(params[:course_id])

		@news = params[:id] ? @course.news.find(params[:id]) : News.new(params[:news])
	end

	def cache_sweep
		expire_fragment(course_path(@course.id, :part => :right))
		expire_fragment(course_news_path(@course.id))
	end
end
