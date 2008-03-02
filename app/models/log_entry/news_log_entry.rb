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

class NewsLogEntry < LogEntry
	def news
		News.find_with_deleted(target_id)
	end
end

class NewsDeleteLogEntry < NewsLogEntry
	def reversible?()
		n = News.find_with_deleted(target_id)
		n.deleted_at != nil
	end
	def undo!(current_user)
		n = News.find_with_deleted(target_id)
		n.update_attribute(:deleted_at, nil)
		NewsRestoreLogEntry.create!(:target_id => n.id, :user_id => current_user.id,
				:course => n.course)
	end
end

class NewsEditLogEntry < NewsLogEntry; end
class NewsCreateLogEntry < NewsLogEntry; end
class NewsRestoreLogEntry < NewsLogEntry; end
