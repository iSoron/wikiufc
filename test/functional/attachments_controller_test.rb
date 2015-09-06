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

require File.dirname(__FILE__) + '/../test_helper'
require 'attachments_controller'

# Re-raise errors caught by the controller.
class AttachmentsController; def rescue_action(e) raise e end; end

class AttachmentsControllerTest < ActionController::TestCase
	fixtures :attachments

	def setup
		@course = Course.first
		@data = fixture_file_upload('/files/attachment.txt', 'text/plain')
		@att = @course.attachments.create(:file => @data, :file_name => 'attachment.txt',
				:description => 'hello world', :path => "", :front_page => true)
		@att.save!
	end

	def teardown
		@data.close!
	end

	context "An anonymous user" do

		should_request_login_on_post_to(:new,	   {:course_id => 1})
		should_request_login_on_post_to(:create,   {:course_id => 1})
		should_request_login_on_post_to(:edit,	   {:course_id => 1, :id => 1})
		should_request_login_on_post_to(:update,   {:course_id => 1, :id => 1})
		should_request_login_on_post_to(:destroy,  {:course_id => 1, :id => 1})

		context "on get to :show" do
			setup { get :show, :course_id => @course.id, :id => @att.id }

			should respond_with :success

			should "link to the attachment" do
				assert_select 'a[href=?]', download_course_attachment_url(@course, @att)
			end
		end
	end

	context "An authenticated user" do
		setup { login_as :bob }

		context "on get to :new" do
			setup { get :new, :course_id => @course.id }
			#should render_a_form
			should respond_with :success
		end

		context "on post to :create" do
			setup do
				assert_nil @course.attachments.find_by_description('test')
				post :create, :course_id => @course.id, :attachment => { :description => 'test', :file => @data, :path => "", :front_page => 't' }
				@att = @course.attachments.find_by_description('test')
			end

			should "create a new attachment" do
				assert @att
			end

			should set_flash.to(/created/i)
			should redirect_to('the attachment') { course_attachment_url(@course, @att) }
			should_create_log_entry {[ AttachmentCreateLogEntry, @att.id, users(:bob).id ]}
		end

		context "on get to :edit" do
			setup { get :edit, :course_id => @course.id, :id => @att.id }
			should render_template 'edit'
		end

		context "on post to :update" do
			context "with unmodified data" do
				setup do
					post :update, :course_id => @course.id, :id => @att.id, :attachment => { :description => @att.description, :path => "", :front_page => 't' }
				end

				should_not set_flash
				should redirect_to('the attachment') { course_attachment_url(@course, @att) }

				should "not create a new log entry" do
					assert_nil AttachmentEditLogEntry.first(:conditions => { :target_id => @att.id })
				end
			end

			context "with new description only" do
				setup do
					post :update, :course_id => @course.id, :id => @att.id, :attachment => { :description => 'new description', :front_page => 't' }
				end
				should set_flash.to(/updated/i)
				should redirect_to('the attachment') { course_attachment_url(@course, @att) }
				should_create_log_entry {[ AttachmentEditLogEntry, @att.id, users(:bob).id ]}
			end

			context "with new file" do
				setup do
					@new_data = fixture_file_upload('/files/another_attachment.txt', 'plain/text')
					post :update, :course_id => @course.id, :id => @att.id, :attachment => { :data => @new_data, :front_page => 't' }
				end
				teardown do
					@new_data.close!
				end
				should set_flash.to(/updated/i)
				should redirect_to('the attachment') { course_attachment_url(@course, @att) }
				should_create_log_entry {[ AttachmentEditLogEntry, @att.id, users(:bob).id ]}
			end
		end

		context "on post to :destroy" do
			setup { post :destroy, :course_id => @course.id, :id => @att.id }

			should set_flash.to(/removed/i)
			should redirect_to('the course page'){ course_url(@course) }
			should_create_log_entry {[ AttachmentDeleteLogEntry, @att.id, users(:bob).id ]}

			should "destroy the attachment" do
				@att = Attachment.with_deleted.find(@att.id)
				assert @att.deleted?
			end
		end

		#context "on post to :undelete" do
		#	setup do
		#		@att.destroy
		#		post :undelete, :course_id => @course.id, :id => @att.id
		#	end

		#	should set_flash.to(/restored/i)
		#	should redirect_to('the attachment'){ course_attachment_url(@course, @att) }
		#	should_create_log_entry {[ AttachmentRestoreLogEntry, @att.id, users(:bob).id ]}

		#	should "restore the attachment" do
		#		assert Attachment.find(@att.id)
		#	end
		#end

		context "on get to :download" do
			setup { get :download, :course_id => @course.id, :id => @att.id }
			should respond_with :success
		end
	end
end
