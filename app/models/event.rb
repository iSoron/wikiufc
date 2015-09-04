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

class Event < ActiveRecord::Base

	# Plugins
	acts_as_paranoid
	acts_as_versioned :if_changed => [ :title, :description, :time ]

	#acts_as_paranoid_versioned
	self.versioned_class.class_eval do
	  def self.delete_all(conditions = nil); return; end
	end

	self.non_versioned_columns << 'deleted_at'

	# Associacoes
	belongs_to :course

	# Validacao
	validates_presence_of :title

	def Event.to_ical(courses)
		courses = [courses] unless courses.kind_of?(Array)
		cal = Icalendar::Calendar.new
		courses.each do |course|
			course.events.each do |e|
				date = DateTime.civil(e.time.year, e.time.month, e.time.day, e.time.hour, e.time.min)
				event = Icalendar::Event.new
				event.start = date
				event.end = date + 1.hour
				event.summary = "#{course.short_name}: #{e.title}"
				event.description = e.description.gsub("\n", "").gsub("\r", "")
				cal.add(event)
			end
		end
		return cal.to_ical
	end

end
