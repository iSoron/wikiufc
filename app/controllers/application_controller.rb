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

require 'yaml'

class ApplicationController < ActionController::Base

	include AuthenticationSystem

	helper :all
	before_filter :startup
	before_filter :set_timezone
	
	# Força o login para algumas áreas do sistema
	before_filter :require_login, :only => [ :edit, :new, :create, :update, :delete, :destroy, :download, :undelete ]

	protected
	def rescue_action(exception)
		# Acesso negado
		if exception.is_a?(AccessDenied)
			respond_to do |format|
				format.html { 
					if logged_in?
						render :file => "#{RAILS_ROOT}/public/401.html", :status => 401
					else
						login_by_html
					end
				}
				format.xml { head 401 }
			end

		# Erro de validacao
		elsif exception.is_a?(ActiveRecord::RecordInvalid)
			respond_to do |format|
				format.html { render :action => (params[:from].nil? ? (exception.record.new_record? ? 'new' : 'edit') : params[:from]) }
				format.xml { render :xml => exception.record.errors, :status => :unprocessable_entity }
			end

		# Registro nao encontrado
		elsif (RAILS_ENV == 'production') and exception.is_a?(ActiveRecord::RecordNotFound)
			respond_to do |format|
				format.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 }
				format.xml { head 404 }
			end

		# Outras excecoes
		else
			super
		end
	end

	def set_timezone
		#Time.zone = session[:user].tz
		Time.zone = "America/Fortaleza"
	end	

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
