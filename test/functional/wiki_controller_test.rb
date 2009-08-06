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
require 'wiki_controller'

# Re-raise errors caught by the controller.
class WikiController; def rescue_action(e) raise e end; end

class WikiControllerTest < ActionController::TestCase
	def setup
		@course = Course.find(:first)

		@wiki_page = @course.wiki_pages.create(:title => 'test1', :content => 'content1',
				:user_id => users(:bob).id, :description => 'test', :version => 1)
		@wiki_page.save!
		@wiki_page.title = 'new title'
		@wiki_page.save!

		@another_wiki_page = @course.wiki_pages.create(:title => 'another', :content => 'another',
				:description => 'test', :user_id => users(:bob).id, :version => 1)
		@another_wiki_page.move_to_bottom
		@another_wiki_page.save!
		@wiki_page.reload

		LogEntry.delete_all
	end

	context "An anonymous user" do

		should_request_login_on_post_to(:new,       {:course_id => 1})
		should_request_login_on_post_to(:create,    {:course_id => 1})
		should_request_login_on_post_to(:edit,      {:course_id => 1, :id => 1})
		should_request_login_on_post_to(:update,    {:course_id => 1, :id => 1})
		should_request_login_on_post_to(:destroy,   {:course_id => 1, :id => 1})
		should_request_login_on_post_to(:move_up,   {:course_id => 1, :id => 1})
		should_request_login_on_post_to(:move_down, {:course_id => 1, :id => 1})
		should_request_login_on_post_to(:undelete,  {:course_id => 1, :id => 1})

		context "on get to :index" do
			setup { get :index, :course_id => @course.id }
			should_redirect_to('the course page') { course_url(@course) }
		end
		
		context "on get to :show" do
			setup { get :show, :course_id => @course.id, :id => @wiki_page.id }

			should_respond_with :success
			should_render_template 'show'

			should "show the wiki page" do
				assert_select 'h1.title', @wiki_page.title
			end

			should "show the selected version" do
				@wiki_page.revert_to(1)
				get :show, :course_id => @course.id, :id => @wiki_page.id, :version => 1
				assert_select 'h1.title', @wiki_page.title
			end
		end

		context "on get to :versions" do
			setup { get :versions, :course_id => @course.id, :id => @wiki_page.id }

			should_respond_with :success
			should_render_template 'versions'

			should "show the wiki page versions" do
				@wiki_page.versions.each do |v|
					assert_select 'a[href=?]', course_wiki_instance_url(@course, @wiki_page, :version => v.version)
				end
			end
		end

		context "on get to :preview" do
			context "with valid markup" do
				setup { get :preview, :text => "hello {$x$} <script>foo();</script> <i onclick='foo()'>x</i>" }

				should_respond_with :success

				should "display latex formulas" do
					assert_select 'img[class=tex_inline]'
				end

				should "strip harmful tags" do
					assert_select 'script', false
					assert_select '*[onclick]', false
				end
			end

			context "with invalid markup" do
				setup { get :preview, :text => "<a" }
				should_respond_with :bad_request
			end
		end

		context "on get to :diff" do
			setup { get :diff, :course_id => @course.id, :id => @wiki_page.id, :from => 1, :to => 2 }
			should_respond_with :success
			should_assign_to :diff
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
				assert_nil @course.wiki_pages.find_by_title('test2')
				post :create, :course_id => @course.id, :wiki_page => { :title => 'test2', :content => 'test2' }
				@wiki_page = @course.wiki_pages.find_by_title('test2')
			end
			
			should_set_the_flash_to(/created/i)
			should_redirect_to('the wiki page') { course_wiki_instance_url(@course, @wiki_page) }
			should_create_log_entry {[ WikiCreateLogEntry, @wiki_page.id, users(:bob).id ]}

			should "create a new wiki page" do
				assert @wiki_page
				assert_equal @wiki_page.version, 1
				assert_equal users(:bob).id, @wiki_page.user_id
			end
		end

		context "on get to :edit" do
			setup { get :edit, :course_id => @course.id, :id => @wiki_page.id }

			should_render_a_form
			should_render_template 'edit'

			should "render a form with the correct fields" do
				assert_select "input[name='wiki_page[title]'][value=?]", @wiki_page.title
				assert_select "input[name='wiki_page[description]'][value=?]", ""
				assert_select 'textarea', @wiki_page.content
			end

			should "edit the selected version" do
				@wiki_page.revert_to(1)
				get :edit, :course_id => @course.id, :id => @wiki_page.id, :version => 1
				assert_select "input[name='wiki_page[title]'][value=?]", @wiki_page.title
				assert_select 'textarea', @wiki_page.content
			end
		end

		context "on post to :update" do
			context "with unmodified data" do
				setup do
					post :update, :course_id => @course.id, :id => @wiki_page.id, :wiki_page => {
							:title => @wiki_page.title, :content => @wiki_page.content}
				end

				should_not_set_the_flash
				should_redirect_to('the wiki page') { course_wiki_instance_url(@course, @wiki_page) }

				should "not create a new log entry" do
					assert_nil WikiEditLogEntry.find(:first, :conditions => { :target_id => @wiki_page.id })
				end
			end

			context "with new data" do
				setup do
					post :update, :course_id => @course.id, :id => @wiki_page.id, :wiki_page => {
							:user_id => 999, :course_id => 999, # not user definable
							:title => 'brand new title', :content => 'brand new content'}
					@wiki_page.reload
				end

				should_set_the_flash_to(/updated/i)
				should_redirect_to('the wiki page') { course_wiki_instance_url(@course, @wiki_page) }
				should_create_log_entry {[ WikiEditLogEntry, @wiki_page.id, users(:bob).id ]}

				should "update the wiki page" do
					assert_equal "brand new title", @wiki_page.title
					assert_equal "brand new content", @wiki_page.content
					assert_equal users(:bob).id, @wiki_page.user_id
					assert_equal @course.id, @wiki_page.course_id
				end
			end
		end

		context "on post to :destroy" do
			setup { post :destroy, :course_id => @course.id, :id => @wiki_page.id }

			should_set_the_flash_to(/removed/i)
			should_redirect_to('the course page') { course_url(@course) }
			should_create_log_entry {[ WikiDeleteLogEntry, @wiki_page.id, users(:bob).id ]}

			should "delete the wiki page" do
				@wiki_page = WikiPage.find_with_deleted(@wiki_page.id)
				assert @wiki_page.deleted?
			end
		end

		context "on get to :move_up" do
			setup do
				assert_equal 1, @wiki_page.position
				assert_equal 2, @another_wiki_page.position
				get :move_up, :course_id => @course.id, :id => @another_wiki_page.id
			end

			should_redirect_to('the course page') { course_url(@course) }

			should "move the page up" do
				@wiki_page.reload
				@another_wiki_page.reload
				assert_equal 2, @wiki_page.position
				assert_equal 1, @another_wiki_page.position
			end
		end

		context "on get to :move_down" do
			setup do
				assert_equal 1, @wiki_page.position
				assert_equal 2, @another_wiki_page.position
				get :move_down, :course_id => @course.id, :id => @wiki_page.id
			end

			should_redirect_to('the course page') { course_url(@course) }

			should "move the page up" do
				@wiki_page.reload
				@another_wiki_page.reload
				assert_equal 2, @wiki_page.position
				assert_equal 1, @another_wiki_page.position
			end
		end

		context "on post to :undelete" do
			setup do
				@wiki_page.destroy
				post :undelete, :course_id => @course.id, :id => @wiki_page.id
			end

			should_set_the_flash_to(/restored/i)
			should_redirect_to('the wiki page') { course_wiki_instance_url(@course, @wiki_page) }
			should_create_log_entry {[ WikiRestoreLogEntry, @wiki_page.id, users(:bob).id ]}

			should "restore the wiki page" do
				assert WikiPage.find(@wiki_page.id)
			end
		end

	end

	#def test_should_accept_text_on_show
	#	get :show, :format => 'txt', :course_id => 1, :id => @wiki_page.id
	#	assert_formatted_response :text
	#end

	#def test_should_accept_html_on_versions
	#	get :versions, :course_id => 1, :id => @wiki_page.id
	#	assert_response :success
	#end

	#def test_should_accept_xml_on_versions
	#	get :versions, :format => 'xml', :course_id => 1, :id => @wiki_page.id
	#	assert_formatted_response :xml, :versions
	#end
end
