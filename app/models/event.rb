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

class Event < ActiveRecord::Base

	acts_as_paranoid
	generate_validations

	belongs_to :course

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
				event.description = e.description
				cal.add(event)
			end
		end
		return cal.to_ical
	end
end
