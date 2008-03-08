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

class LogEntry < ActiveRecord::Base
	belongs_to :user
	belongs_to :course

	acts_as_paranoid

	def reversible?() false end

	def to_xml(options = {})
		options[:indent] ||= 2
		xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
		xml.instruct! unless options[:skip_instruct]
		xml.log_entry do
			xml.id self.id
			xml.course_id self.course_id
			xml.created_at self.created_at
			xml.target_id self.target_id
			xml.user_id self.user_id
			xml.type self.type
			xml.version self.version unless self.version.nil?
		end
	end
end

require 'log_entry/attachment_log_entry.rb'
require 'log_entry/event_log_entry.rb'
require 'log_entry/news_log_entry.rb'
require 'log_entry/wiki_log_entry.rb'
