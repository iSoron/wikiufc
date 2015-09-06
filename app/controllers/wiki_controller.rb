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

class WikiController < ApplicationController
  # verify params: :text, only: :preview, redirect_to: { action: :show }
  # verify params: [:from, :to], only: :diff, redirect_to: { action: :versions }

  before_filter :find_wiki, except: [:preview]
  before_filter :require_login, only: [:new, :create, :edit, :update, :destroy,
                                       :move_up, :move_down]

  def index
    @wiki_pages = @course.wiki_pages

    respond_to do |format|
      format.html
      format.xml { render xml: @wiki_pages }
    end
  end

  def new
  end

  def create
    @wiki_page.version = 1
    @wiki_page.user_id = session[:user_id]
    @wiki_page.course_id = @course.id
    @wiki_page.description = t(:new_wiki_page)
    @wiki_page.save!
    flash[:notice] = t(:wiki_page_created)

    WikiCreateLogEntry.create!(target_id: @wiki_page.id, user: @current_user,
                               course: @course)

    respond_to do |format|
      format.html do
        redirect_to course_wiki_instance_url(@course, @wiki_page)
      end
      format.xml do
        head :created, location: course_wiki_instance_url(@course, @wiki_page,
                                                          format: :xml)
      end
    end
  end

  def show
    @wiki_page.revert_to(params[:version]) if params[:version]

    respond_to do |format|
      format.html
      format.xml { render xml: @wiki_page }
      format.text { render text: "# #{@wiki_page.title}\n\n#{@wiki_page.content}" }
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
      WikiEditLogEntry.create!(target_id: @wiki_page.id, user: @current_user, course: @course, version: @wiki_page.version)
      flash[:notice] = t(:wiki_page_updated)
    end

    respond_to do |format|
      format.html { redirect_to course_wiki_instance_url(@course, @wiki_page) }
      format.xml { head :created, location: course_wiki_instance_url(@course, @wiki_page, format: :xml) }
    end
  end

  def destroy
    @wiki_page.remove_from_list
    @wiki_page.destroy
    flash[:notice] = t(:wiki_page_removed)

    log = WikiDeleteLogEntry.create!(target_id: @wiki_page.id, user: @current_user, course: @course)
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
      render text: @text.format_wiki
    rescue RuntimeError
      render text: $ERROR_INFO.to_s.gsub(">", "&gt;").gsub("<", "&lt;"),
             status: :bad_request
    end
  end

  def diff
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
    @course = Course.from_param(params[:course_id])

    if params[:id]
      @wiki_page = WikiPage.from_param(@course, params[:id])
    else
      @wiki_page = WikiPage.new(params[:wiki_page])
    end
  end
end
