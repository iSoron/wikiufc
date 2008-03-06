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

class WikiLogEntry < LogEntry
	def wiki_page
		w = WikiPage.find_with_deleted(target_id)
		w.revert_to(version)
		return w
	end
end

class WikiEditLogEntry < WikiLogEntry
	validates_presence_of :version
end

class WikiDeleteLogEntry < WikiLogEntry
	def reversible?()
		w = WikiPage.find_with_deleted(target_id)
		w.deleted_at != nil
	end
	def undo!(current_user)
		w = WikiPage.find_with_deleted(target_id)
		w.update_attribute(:deleted_at, nil)
		w.position = w.course.wiki_pages.maximum(:position) + 1
		w.save!
		WikiRestoreLogEntry.create!(:target_id => w.id, :user_id => current_user.id,
				:course => w.course)
	end
end

class WikiCreateLogEntry < WikiLogEntry; end
class WikiRestoreLogEntry < WikiLogEntry; end

