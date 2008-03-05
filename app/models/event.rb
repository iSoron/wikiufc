# Engenharia de Software 2007.1
# Copyright (C) 2007, Adriano, Alinson, Andre, Rafael e Bustamante
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

class Event < ActiveRecord::Base

	acts_as_paranoid
	generate_validations

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
