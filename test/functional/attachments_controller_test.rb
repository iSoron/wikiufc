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
require 'attachments_controller'

# Re-raise errors caught by the controller.
class AttachmentsController; def rescue_action(e) raise e end; end

class AttachmentsControllerTest < Test::Unit::TestCase
	fixtures :attachments

	def setup
		@controller = AttachmentsController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_truth
		assert true
	end

#
#	def test_index
#		get :index
#		assert_response :success
#		assert_template 'list'
#	end
#
#	def test_list
#		get :list
#
#		assert_response :success
#		assert_template 'list'
#
#		assert_not_nil assigns(:attachments)
#	end
#
#	def test_show
#		get :show, :id => @first_id
#
#		assert_response :success
#		assert_template 'show'
#
#		assert_not_nil assigns(:attachment)
#		assert assigns(:attachment).valid?
#	end
#
#	def test_new
#		get :new
#
#		assert_response :success
#		assert_template 'new'
#
#		assert_not_nil assigns(:attachment)
#	end
#
#	def test_create
#		num_attachments = Attachment.count
#
#		post :create, :attachment => {}
#
#		assert_response :redirect
#		assert_redirected_to :action => 'list'
#
#		assert_equal num_attachments + 1, Attachment.count
#	end
#
#	def test_edit
#		get :edit, :id => @first_id
#
#		assert_response :success
#		assert_template 'edit'
#
#		assert_not_nil assigns(:attachment)
#		assert assigns(:attachment).valid?
#	end
#
#	def test_update
#		post :update, :id => @first_id
#		assert_response :redirect
#		assert_redirected_to :action => 'show', :id => @first_id
#	end
#
#	def test_destroy
#		assert_nothing_raised {
#			Attachment.find(@first_id)
#		}
#
#		post :destroy, :id => @first_id
#		assert_response :redirect
#		assert_redirected_to :action => 'list'
#
#		assert_raise(ActiveRecord::RecordNotFound) {
#			Attachment.find(@first_id)
#		}
#	end
end
