# -*- encoding : utf-8 -*-
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

class LogEntry < ActiveRecord::Base

	# Plugins
	acts_as_paranoid

	# Associacoes
	belongs_to :course
	belongs_to :user, :with_deleted => true

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

load 'log_entry/attachment_log_entry.rb'
load 'log_entry/event_log_entry.rb'
load 'log_entry/news_log_entry.rb'
load 'log_entry/wiki_log_entry.rb'
