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

require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase

    context "An authenticated user" do
        setup { login_as :bob }

        context "on get to :dashboard" do
            setup { get :dashboard }

            should_respond_with :success
            should_render_template "dashboard"
        end

        context "on post to :logout" do
            setup { get :logout }

            should_respond_with :redirect
			should_redirect_to('the main page') { index_url }

            should "log out" do
                assert_nil session[:user_id]
                assert_nil cookies[:login_token]
            end
        end

    end
end
