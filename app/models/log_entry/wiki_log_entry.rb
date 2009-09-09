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

class WikiLogEntry < LogEntry
	belongs_to :wiki_page,
	           :foreign_key => "target_id",
	           :with_deleted => true
end

class WikiEditLogEntry < WikiLogEntry
	validates_presence_of :version
end

class WikiDeleteLogEntry < WikiLogEntry
	def reversible?()
		wiki_page.deleted?
	end
	def undo!(current_user)
		wiki_page.update_attribute(:position, (wiki_page.course.wiki_pages.maximum(:position)||0) + 1)
		wiki_page.update_attribute(:deleted_at, nil)
		WikiRestoreLogEntry.create!(:target_id => wiki_page.id, :user_id => current_user.id, :course => wiki_page.course)
	end
end

class WikiCreateLogEntry < WikiLogEntry; end
class WikiRestoreLogEntry < WikiLogEntry; end

