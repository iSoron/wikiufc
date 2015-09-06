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

require File.dirname(__FILE__) + '/../test_helper.rb'
require 'courses_controller'

# Re-raise errors caught by the controller.
# class CoursesController; def rescue_action(e) raise e end; end

class CoursesControllerTest < ActionController::TestCase
  def setup
    @course = courses(:course_1)
    @course_id = @course.id
    @old_course = courses(:old_course)
    LogEntry.delete_all
  end

  context "An anonymous user" do
    should_request_login_on_post_to(:new)
    should_request_login_on_post_to(:create)
    should_request_login_on_post_to(:edit, id: 0)
    should_request_login_on_post_to(:update, id: 0)
    should_request_login_on_post_to(:destroy, id: 0)
    should_request_login_on_post_to(:enroll, id: 0)
    should_request_login_on_post_to(:unenroll, id: 0)

    context "on get to :index" do
      setup { get :index }

      should respond_with :success
      should render_template 'index'

      should "display the course list" do
        assert_select 'h1', "Disciplinas #{App.current_period}"
        assert_select 'a[href=?]', course_url(@course)
      end

      should "display the selected period" do
        get :index, period: "1970.1"
        assert_select 'h1', "Disciplinas 1970.1"
      end
    end

    context "on get to :show" do
      setup do
        get :show, id: @course.id
      end

      should respond_with :success
      should render_template 'show'

      should "display the course" do
        assert_select 'a[href=?]', course_log_url(@course)
        assert_select 'h1', @course.full_name
      end
    end
  end

  context "on :show unknown course" do
    setup { get :show, id: 891729312 }
    should respond_with :missing
  end

  context "A regular user" do
    setup do
      login_as :bob
    end

    should_have_access_denied_on_post_to(:new)
    should_have_access_denied_on_post_to(:create)
    should_have_access_denied_on_post_to(:edit, id: 0)
    should_have_access_denied_on_post_to(:update, id: 0)
    should_have_access_denied_on_post_to(:destroy, id: 0)

    context "on get to :enroll" do
      setup { get :enroll, id: @course.id }

      should respond_with :redirect
      should redirect_to('courses') { courses_path }

      should "enroll on the course" do
        assert @user.courses.include?(@course)
      end
    end

    context "on get to :unenroll" do
      setup do
        @user.courses << @course
        get :unenroll, id: @course.id
      end

      should respond_with :redirect
      should redirect_to('courses') { courses_path }

      should "disenroll from the course" do
        assert !@user.courses.include?(@course)
      end
    end
  end

  context "An admin" do
    setup do
      login_as :admin
    end

    context "on post to :create" do
      setup do
        post :create, course: { full_name: 'New Course',
                                short_name: 'new_course', code: 'CK001',
                                grade: '1', period: '2007.1', hidden: false,
                                description: '' }
      end

      should respond_with :redirect
      should set_flash.to(/created/i)
      should redirect_to('the new course') { course_path(assigns(:course)) }
    end

    context "on get to :edit" do
      setup { get :edit, id: @course.id }

      should respond_with :success
      should render_template 'edit'
      should 'assign to :course' do
        assert assigns(:course)
      end
    end

    context "on post to :update" do
      setup do
        post :update, id: @course.id,
                      course: { full_name: 'new full name',
                                short_name: 'new_short_name',
                                code: 'CK9999', grade: '999', period: '2999.1',
                                hidden: true,
                                description: 'new description' }
      end

      should respond_with :redirect
      should redirect_to('the updated course') { course_path(assigns(:course)) }

      should "update attributes of course" do
        @course = Course.find(@course.id)
        assert @course.full_name == 'new full name'
        assert @course.short_name == 'new_short_name'
        assert @course.code == 'CK9999'
        assert @course.grade == 999
        assert @course.period == '2999.1'
        assert @course.hidden == true
        assert @course.description == 'new description'
      end
    end

    context "on post to :update with invalid data" do
      setup do
        post :update, id: @course.id,
                      course: { full_name: '',
                                short_name: '',
                                code: '', grade: 'xxx', period: '',
                                hidden: 'xxx',
                                description: '' }
      end

      should respond_with :success
      should render_template 'edit'
    end

    context "on post to :destroy" do
      setup { post :destroy, id: @course.id }

      should respond_with :redirect
      should redirect_to('courses') { courses_path }

      should "remove course from db" do
        assert_raise ActiveRecord::RecordNotFound do
          Course.find(@course.id)
        end
      end
    end
  end

  # context "A user" do
  #	setup { login_as :bob }
  #	should_be_restful do |resource|
  #		resource.create.params = { short_name: 'test', full_name: 'test', description: 'test' }
  #		resource.update.params = { short_name: 'test', full_name: 'test', description: 'test' }
  #	end
  # end

  ## REST - usuários quaisquer
  # context "A stranger" do
  #	setup { logout }
  #	should_be_restful do |resource|
  #		resource.create.params = { short_name: 'test', full_name: 'test', description: 'test' }
  #		resource.update.params = { short_name: 'test', full_name: 'test', description: 'test' }
  #		resource.denied.actions = [ :new, :edit, :create, :update, :destroy ]
  #		resource.denied.redirect = "'/login'"
  #		resource.denied.flash = /must be logged in/i
  #	end
  # end
end
