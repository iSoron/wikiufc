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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.

class CoursesController < ApplicationController

	before_filter :require_admin, :only => [ :new, :create, :edit, :update, :destroy ]
	before_filter :require_login, :only => [ :enroll, :unenroll ]
	before_filter :find_course, :except => [ :index ]
	#after_filter :cache_sweep, :only => [ :create, :update, :destroy ]

	def index
		@courses = Course.find(:all, :order => 'period asc, full_name asc')

		respond_to do |format|
			format.html
			format.xml { render :xml => @courses }
		end
	end

	def show
		respond_to do |format|
			format.html
			format.xml { render :xml => @course }
		end
	end
	
	def new
	end

	def create
		@course.save!
		flash[:notice] = 'Course created'[]

		respond_to do |format|
			format.html { redirect_to course_path(@course) }
			format.xml { head :created, :location => formatted_course_url(@course, :xml) }
		end
	end

	def edit
	end

	def update
		@course.attributes = params[:course]
		@course.save!

		flash[:notice] = 'Course updated'[]
		respond_to do |format|
			format.html { redirect_to course_path(@course) }
			format.xml { head :ok }
		end
	end

	def destroy
		@course.destroy
		flash[:notice] = 'Course removed'[]

		respond_to do |format|
			format.html { redirect_to courses_path }
			format.xml { head :ok }
		end
	end

	def enroll
		@current_user.courses << @course
		flash[:highlight] = @course.id

		respond_to do |format|
			format.html { redirect_to courses_path }
			format.xml { head :ok }
		end
	end

	def unenroll
		@current_user.courses.delete(@course)
		flash[:highlight] = @course.id

		respond_to do |format|
			format.html { redirect_to courses_path }
			format.xml { head :ok }
		end
	end

	protected
	def find_course
		params[:id] = Course.find_by_short_name(params[:id]).id if params[:id] and !params[:id].is_numeric? and !Course.find_by_short_name(params[:id]).nil?
		@course = params[:id] ? Course.find(params[:id]) : Course.new(params[:course])
	end

	def require_admin
		raise AccessDenied.new unless admin?
	end

	def cache_sweep
		expire_fragment(course_path(@course.id, :part => 'right'))
		expire_fragment(course_path(@course.id))
		expire_fragment(courses_path)
	end
end
