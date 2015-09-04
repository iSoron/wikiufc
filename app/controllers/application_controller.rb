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

require 'yaml'
require 'authentication.rb'

class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  include AuthenticationSystem

  before_filter :startup
  # before_filter :set_timezone
  before_filter :require_login, only: [:edit, :new, :create, :update, :delete,
                                       :destroy]

  rescue_from AccessDenied, with: :deny_access
  rescue_from ActiveRecord::RecordInvalid, with: :reshow_form
  rescue_from ActiveRecord::RecordNotFound, with: :show_not_found

  protected

  def deny_access
    respond_to do |format|
      format.html do
        if logged_in?
          render file: "#{Rails.root}/public/401.html", status: 401
        else
          login_by_html
        end
      end
      format.xml { head 401 }
    end
  end

  def reshow_form(exception)
    respond_to do |format|
      format.html { render action: (params[:from].nil? ? (exception.record.new_record? ? 'new' : 'edit') : params[:from]) }
      format.xml { render xml: exception.record.errors, status: :unprocessable_entity }
    end
  end

  def show_not_found
    if (RAILS_ENV == 'production')
      respond_to do |format|
        format.html { render file: "#{Rails.root}/public/404.html", status: 404 }
        format.xml { head 404 }
      end
    else
      fail ActiveRecord::RecordNotFound
    end
  end

  # def set_timezone
  #  #Time.zone = session[:user].tz
  #  Time.zone = "America/Fortaleza"
  # end

  def startup
    if session[:user_id]
      @current_user = User.find(session[:user_id])
    else
      login_by_token
    end

    @color = App.default_color
    @color = @current_user.pref_color if @current_user
    @color = params[:color].to_i if params[:color]
  end
end
