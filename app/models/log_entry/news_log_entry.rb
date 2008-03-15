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

class NewsLogEntry < LogEntry
	belongs_to :news,
               :foreign_key => "target_id",
               :with_deleted => true
end

class NewsDeleteLogEntry < NewsLogEntry
	def reversible?()
        news.deleted?
	end
	def undo!(current_user)
		news.update_attribute(:deleted_at, nil)
		NewsRestoreLogEntry.create!(:target_id => news.id, :user_id => current_user.id, :course => news.course)
	end
end

class NewsEditLogEntry < NewsLogEntry; end
class NewsCreateLogEntry < NewsLogEntry; end
class NewsRestoreLogEntry < NewsLogEntry; end
