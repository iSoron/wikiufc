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

class CoursesController < ApplicationController
  before_filter :require_admin, only: [:new, :create, :edit, :update,
                                       :destroy]
  before_filter :require_login, only: [:enroll, :unenroll]
  before_filter :find_course, except: [:index]
  # after_filter :cache_sweep, only: [ :create, :update, :destroy ]

  def index
    @period = params[:period] || App.current_period
    @courses = Course.visible.where(period: @period)

    respond_to do |format|
      format.html
      format.xml { render xml: @courses }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml { render xml: @course }
    end
  end

  def new
  end

  def create
    @course.save!
    flash[:notice] = t(:course_created)

    respond_to do |format|
      format.html { redirect_to course_path(@course) }
      format.xml do
        head :created, location: course_url(@course, format: :xml)
      end
    end
  end

  def edit
  end

  def update
    @course.attributes = params[:course]
    @course.save!

    flash[:notice] = t(:course_updated)
    respond_to do |format|
      format.html { redirect_to course_path(@course) }
      format.xml { head :ok }
    end
  end

  def destroy
    @course.destroy
    flash[:notice] = t(:course_removed)

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
    if params[:id]
      @course = Course.from_param(params[:id])
    else
      @course = Course.new(params[:course])
    end
  end

  def require_admin
    fail AccessDenied, 'only admins can modify courses' unless admin?
  end

  def cache_sweep
    expire_fragment(course_path(@course.id, part: 'right'))
    expire_fragment(course_path(@course.id))
    expire_fragment(courses_path)
  end
end
