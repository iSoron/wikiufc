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

class UsersController < ApplicationController

	before_filter :find_user, :only => [ :show, :edit, :update, :destroy, :signup ]
	before_filter :require_login, :only => [ :settings ]
	before_filter :require_admin, :only => [ :edit, :update, :destroy ]

	def index
		@users = User.find(:all, :order => 'name')

		respond_to do |format|
			format.html
			format.xml { render :xml => @users }
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
		raise AccessDenied.new unless (params[:user][:login] == @user.login)
		raise AccessDenied.new unless (params[:user][:admin].nil? or @current_user.admin?)
		@user.admin = !params[:user][:admin].nil?

		@user.attributes = params[:user]
		@user.save!
		flash[:notice] = 'User account updated'[]

		respond_to do |format|
			format.html { redirect_to user_path(@user) }
			format.xml { head :ok }
		end
	end

	def destroy
		@user.destroy
		flash[:notice] = 'User account removed'[]

		respond_to do |format|
			format.html { redirect_to users_path }
			format.xml { head :ok }
		end
	end

	def signup
		if request.post?
			begin
				@user.last_seen = Time.now.utc
				@user.save!
				setup_session(@user)
				flash[:message] = 'User account created'[]
				redirect_to user_path(@user)
			rescue ActiveRecord::RecordInvalid
				flash[:warning] = 'Não foi possível cadastrar a conta.'
			end
		end
	end

	def settings
		@user = @current_user
		if request.post?
			@user.attributes = params[:user]
			@user.save!
			@color = @user.pref_color
			flash[:message] = 'Settings updated'[]
			redirect_to index_path
		end
	end

	def login
		if request.post?
			@user = User.find_by_login_and_pass(params[:user][:login], params[:user][:password])
			if !@user.nil?
				setup_session(@user, (params[:remember_me] == "1"))
				@user.update_attribute(:last_seen, Time.now.utc)
				flash[:message] = 'Welcome back, {u}'[:login_success, @user.login]
				redirect_to_stored
			else
				flash[:warning] = 'Login failed'
			end
		end
	end

	def logout
		destroy_session
		flash[:message] = 'You have logged out'[:logout_success]
		redirect_to index_path
	end

	def dashboard
		@news = []
		@events = []

		unless @current_user.courses.empty?
			@news = News.find(:all, :conditions => [ 'receiver_id in (?)', @current_user.courses ],
					:order => 'timestamp desc', :limit => 5)
			@events = Event.find(:all, :conditions => [ 'course_id in (?) and (date > ?) and (date < ?)',
			@current_user.courses, 1.day.ago, 21.days.from_now ], :order => 'date')
		end
	end

#	def forgot_password
#		if request.post?
#			u = User.find_by_email(params[:user][:email])
#			if u and u.send_new_password
#				flash[:message] = "Uma nova senha foi enviada para o seu email."
#				redirect_to :action=>'login'
#			else
#				flash[:warning] = "Não foi possível gerar uma nova senha."
#			end
#		end
#	end

	#Funções do Fórum
	protected
	def find_user
		params[:id] = User.find_by_login(params[:id]).id if params[:id] and !params[:id].is_numeric?
		@user = params[:id] ? User.find(params[:id]) : User.new(params[:user])
	end

	def require_admin
		raise AccessDenied.new unless admin? or @current_user == @user
	end
end
