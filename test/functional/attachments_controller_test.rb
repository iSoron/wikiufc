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

class AttachmentsControllerTest < ActionController::TestCase
	fixtures :attachments

	def setup
		@course = Course.find(:first)
		@data = fixture_file_upload('/files/attachment.txt', 'text/plain')
		@att = @course.attachments.create(:file => @data, :file_name => 'attachment.txt', :description => 'hello world')
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
		should_request_login_on_post_to(:undelete, {:course_id => 1, :id => 1})

		context "on get to :show" do
			setup { get :show, :course_id => @course.id, :id => @att.id }

			should_respond_with :success

			should "link to the attachment" do
				assert_select 'a[href=?]', download_course_attachment_url(@course, @att)
			end
		end
	end

	context "An authenticated user" do
		setup { login_as :bob }

		context "on get to :new" do
			setup { get :new, :course_id => @course.id }
			should_render_a_form
			should_respond_with :success
		end

		context "on post to :create" do
			setup do
				assert_nil @course.attachments.find_by_description('test')
				post :create, :course_id => @course.id, :attachment => { :description => 'test', :file => @data }
				@att = @course.attachments.find_by_description('test')
			end
			
			should "create a new attachment" do
				assert @att
			end

			should_set_the_flash_to(/created/i)
			should_redirect_to('the attachment') { course_attachment_url(@course, @att) }
			should_create_log_entry {[ AttachmentCreateLogEntry, @att.id, users(:bob).id ]}
		end

		context "on get to :edit" do
			setup { get :edit, :course_id => @course.id, :id => @att.id }
			should_render_a_form
			should_render_template 'edit'
		end

		context "on post to :update" do
			context "with unmodified data" do
				setup do
					post :update, :course_id => @course.id, :id => @att.id, :attachment => { :description => @att.description }
				end

				should_not_set_the_flash
				should_redirect_to('the attachment') { course_attachment_url(@course, @att) }

				should "not create a new log entry" do
					assert_nil AttachmentEditLogEntry.find(:first, :conditions => { :target_id => @att.id })
				end
			end

			context "with new description only" do
				setup do
					post :update, :course_id => @course.id, :id => @att.id, :attachment => { :description => 'new description' }
				end
				should_set_the_flash_to(/updated/i)
				should_redirect_to('the attachment') { course_attachment_url(@course, @att) }
				should_create_log_entry {[ AttachmentEditLogEntry, @att.id, users(:bob).id ]}
			end

			context "with new file" do
				setup do
					@new_data = fixture_file_upload('/files/another_attachment.txt', 'plain/text')
					post :update, :course_id => @course.id, :id => @att.id, :attachment => { :data => @new_data }
				end
				teardown do
					@new_data.close!
				end
				should_set_the_flash_to(/updated/i)
				should_redirect_to('the attachment') { course_attachment_url(@course, @att) }
				should_create_log_entry {[ AttachmentEditLogEntry, @att.id, users(:bob).id ]}
			end
		end

		context "on post to :destroy" do
			setup { post :destroy, :course_id => @course.id, :id => @att.id }

			should_set_the_flash_to(/removed/i)
			should_redirect_to('the course page'){ course_url(@course) }
			should_create_log_entry {[ AttachmentDeleteLogEntry, @att.id, users(:bob).id ]}

			should "destroy the attachment" do
				@att = Attachment.find_with_deleted(@att.id)
				assert @att.deleted?
			end
		end

		context "on post to :undelete" do
			setup do
				@att.destroy
				post :undelete, :course_id => @course.id, :id => @att.id
			end

			should_set_the_flash_to(/restored/i)
			should_redirect_to('the attachment'){ course_attachment_url(@course, @att) }
			should_create_log_entry {[ AttachmentRestoreLogEntry, @att.id, users(:bob).id ]}

			should "restore the attachment" do
				assert Attachment.find(@att.id)
			end
		end

		context "on get to :download" do
			setup { get :download, :course_id => @course.id, :id => @att.id }
			should_respond_with :success
		end
	end
end
