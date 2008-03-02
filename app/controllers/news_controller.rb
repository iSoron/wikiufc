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

class NewsController < ApplicationController

	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	#verify :method => :post, :only => [ :destroy, :create, :update ],
	#	:redirect_to => { :action => :list }

	before_filter :find_new, :except => [ :undelete ]
	after_filter :cache_sweep, :only => [ :create, :update, :destroy ]

	def index
		@news = @course.news
		respond_to do |format|
			format.html
			format.xml { render :xml => @news }
			format.rss { response.content_type = Mime::RSS }
		end
	end

	def show
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
		flash[:notice] = 'News created'[]

		NewsCreateLogEntry.create!(:target_id => @news.id, :user => @current_user, :course => @course)

		respond_to do |format|
			format.html { redirect_to course_news_path(@course, @news) }
			format.xml { head :created, :location => formatted_course_news_url(@course, @news, :xml) }
		end
	end

	def edit
	end

	def update
		@news.attributes = params[:news]
		@news.save!
		flash[:notice] = 'News updated'[]

		NewsEditLogEntry.create!(:target_id => @news.id, :user => @current_user, :course => @course)

		respond_to do |format|
			format.html { redirect_to course_news_path(@course, @news) }
			format.xml { head :created, :location => formatted_course_news_url(@course, @news, :xml) }
		end
	end

	def destroy
		@news.destroy
		flash[:notice] = 'News removed'[]
		flash[:undo] = undelete_course_news_url(@course, @news)

		NewsDeleteLogEntry.create!(:target_id => @news.id, :user => @current_user, :course => @course)

		respond_to do |format|
			format.html { redirect_to course_news_index_path(@course) }
			format.xml { head :ok }
		end
	end

	def undelete
		@news = News.find_with_deleted(params[:id])
		@news.update_attribute(:deleted_at, nil)
		flash[:notice] = "News restored"[]

		NewsRestoreLogEntry.create!(:target_id => @news.id, :user => @current_user, :course => @course)
		
		respond_to do |format|
			format.html { redirect_to course_news_url(@news.course, @news) }
		end
	end


	protected
	def find_new
		params[:course_id] = Course.find_by_short_name(params[:course_id]).id if !params[:course_id].is_numeric? and !Course.find_by_short_name(params[:course_id]).nil?
		@course = Course.find(params[:course_id])

		@news = params[:id] ? @course.news.find(params[:id]) : News.new(params[:news])
	end

	def cache_sweep
		expire_fragment(:controller => 'courses', :action => 'show', :part => 'right')
		expire_fragment(:action => 'index')
	end
end
