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

WikiUFC::Application.routes.draw do

    resources :users

    resources :courses do
        member do
            get :enroll
            get :unenroll
        end

        resources :events do
            member do
                post :undelete
            end
        end

        resources :news do
            member do
                post :undelete
            end
        end

        resources :wiki do
            member do
                get :move_down
                post :undelete
                get :diff
                get :versions
                get :move_up
            end
        end

        resources :attachments do
            member do
                post :undelete
                get :download
            end
        end
    end

	# Log
    #match 'controllerlog' => '#index', :as => :with_options

    # Services
    match 'services/preview' => 'wiki#preview', :as => :preview

    # Widgets
    match 'widgets/calendar/:id/:year/:month' => 'events#mini_calendar'

    # Authentication
	with_options :controller => 'users' do |user|
		user.match 'login',    :action => 'login'
		user.match 'logout',   :action => 'logout'
		user.match 'signup',   :action => 'signup'
		user.match 'settings', :action => 'settings'
		user.match 'recover_password', :action => 'recover_password'
		user.match 'recover_password/:key', :action => 'recover_password'
    end

	# Pagina pessoal
    match '/dashboard' => 'users#dashboard', :as => :dashboard
    match '/dashboard/:secret.:format' => 'users#dashboard', :as => :formatted_dashboard

	# Stylesheets
    match 'stylesheets/cache/:action.:format' => 'stylesheets#index'
    match 'stylesheets/cache/:action.:color.:format' => 'stylesheets#index'

	# Mudancas recentes global
    match 'log' => 'log#index', :as => :log, :format => 'html'
    match 'log.:format' => 'log#index', :as => :formatted_log
    
	# Front page
    match '' => 'courses#index', :as => :index
end

