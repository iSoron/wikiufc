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

class UsersController < ApplicationController

	before_filter :find_user, :only => [ :show, :edit, :update, :destroy, :signup ]
	before_filter :require_login, :only => [ :settings ]
	before_filter :require_admin, :only => [ :edit, :update, :destroy ]

	def index
		@users = User.paginate(:page => params[:page], :per_page => 20, :order => 'last_seen desc')

		respond_to do |format|
			format.html
			format.xml { render :xml => User.find(:all) }
		end
	end

	def show
		respond_to do |format|
			format.html
			format.xml { render :xml => @user }
		end
	end

	def edit
	end

	def update
		raise AccessDenied.new unless params[:user][:login].nil?
		raise AccessDenied.new unless (params[:user][:admin].nil? or @current_user.admin?)
		@user.admin = !params[:user][:admin].nil?

		@user.attributes = params[:user]
		@user.save!
		flash[:notice] = t(:user_account_updated)

		respond_to do |format|
			format.html { redirect_to user_path(@user) }
			format.xml { head :ok }
		end
	end

	def destroy
		@user.destroy
		flash[:notice] = t(:user_account_removed)

		respond_to do |format|
			format.html { redirect_to users_path }
			format.xml { head :ok }
		end
	end

	def signup
		if request.post?
			begin
				@user.login.downcase!
				@user.last_seen = Time.now.utc
				@user.save!
				setup_session(@user)
				flash[:message] = t(:user_account_created)
				redirect_to dashboard_url
			rescue ActiveRecord::RecordInvalid
				flash[:warning] = 'Não foi possível cadastrar a conta.'
			end
		end
	end

	def settings
		@user = @current_user
		if request.post?
			raise AccessDenied.new unless params[:user][:login].nil?
			@user.attributes = params[:user]
			@user.save!
			@color = @user.pref_color
			flash[:message] = t(:settings_updated)
			redirect_to dashboard_url
		end
	end

	def login
		if request.post?
			params[:user][:login].downcase!
			@user = User.find_by_login_and_pass(params[:user][:login], params[:user][:password])
			if !@user.nil?
				setup_session(@user, (params[:remember_me] == "1"))
				@user.update_attribute(:last_seen, Time.now.utc)
				flash[:message] = t(:welcome_back, :u => @user.login)
				redirect_to_stored
			else
				flash[:warning] = t(:login_failed)
			end
		end
	end

	def logout
		destroy_session
		flash[:message] = t(:logout_success)
		redirect_to index_path
	end

	def dashboard
		@news = []
		@events = []

		if params[:secret]
			@user = User.find_by_secret(params[:secret])
		else
			return require_login unless logged_in?
			@user = @current_user
		end

		unless @user.courses.empty?
			@news = News.find(:all, :conditions => [ 'receiver_id in (?)', @user.courses ],
					:order => 'timestamp desc', :limit => 20)
			@events = Event.find(:all, :conditions => [ 'course_id in (?) and (time > ?) and (time < ?)',
					@user.courses, 1.day.ago, 21.days.from_now ], :order => 'time')
		end

		respond_to do |format|
			format.html
			format.rss { response.content_type = Mime::RSS }
			format.ics { response.content_type = Mime::ICS; render :text => Event.to_ical(@user.courses) }
		end
	end

	def recover_password
		if params[:key]
			@user = User.find_by_password_reset_key(params[:key])
			if @user.nil?
				redirect_to login_path
			elsif request.post?
				@user.password = params[:user][:password]
				@user.password_confirmation = params[:user][:password_confirmation]
				if @user.save
					@user.update_attribute(:password_reset_key, nil)
					flash[:message] = "Senha modificada"
					redirect_to login_path
				end
			end
		else
			if request.post?
				@user = User.find_by_email(params[:user][:email])
				if @user.nil?
					flash[:warning] = "Email inválido"
				else
					@user.generate_password_reset_key!
				end
			end
		end
	end

	protected
	def find_user
		params[:id] = User.find_by_login(params[:id]).id if params[:id] and !params[:id].is_numeric?
		@user = params[:id] ? User.find(params[:id]) : User.new(params[:user])
	end

	def require_admin
		raise AccessDenied.new unless admin? or @current_user == @user
	end
end
