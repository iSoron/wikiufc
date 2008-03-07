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

class EventLogEntry < LogEntry
	def event
		Event.find_with_deleted(target_id)
	end
end

class EventDeleteLogEntry < EventLogEntry
	def reversible?()
		e = Event.find_with_deleted(target_id)
		e.deleted_at != nil
	end
	def undo!(current_user)
		e = Event.find_with_deleted(target_id)
		e.update_attribute(:deleted_at, nil)
		EventRestoreLogEntry.create!(:target_id => e.id, :user_id => current_user.id,
				:course_id => e.course_id)
	end
end

class EventEditLogEntry < EventLogEntry; end
class EventCreateLogEntry < EventLogEntry; end
class EventRestoreLogEntry < EventLogEntry; end
