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

#require File.dirname(__FILE__) + '/../test_helper'
#
#class NotificationsTest < ActiveSupport::TestCase
#	FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
#	CHARSET = "utf-8"
#
#	#include ActionMailer::Quoting
#
#	def setup
#		ActionMailer::Base.delivery_method = :test
#		ActionMailer::Base.perform_deliveries = true
#		ActionMailer::Base.deliveries = []
#
#		@expected = TMail::Mail.new
#		@expected.set_content_type "text", "plain", { "charset" => CHARSET }
#		@expected.mime_version = '1.0'
#	end
#
#	def test_forgot_password
#		@expected.subject = 'Notifications#forgot_password'
#		@expected.body    = read_fixture('forgot_password')
#		@expected.date    = Time.now
#
#		#assert_equal @expected.encoded, Notifications.create_forgot_password(@expected.date).encoded
#	end
#
#	private
#	def read_fixture(action)
#		IO.readlines("#{FIXTURES_PATH}/notifications/#{action}")
#	end
#
#	def encode(subject)
#		quoted_printable(subject, CHARSET)
#	end
#end
#