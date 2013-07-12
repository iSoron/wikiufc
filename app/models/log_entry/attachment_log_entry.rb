# -*- encoding : utf-8 -*-
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

class AttachmentLogEntry < LogEntry
	belongs_to :attachment,
               :foreign_key => "target_id",
               :with_deleted => true
end

class AttachmentDeleteLogEntry < AttachmentLogEntry
	def reversible?()
        attachment.deleted?
	end
	def undo!(current_user)
		attachment.update_attribute(:deleted_at, nil)
		AttachmentRestoreLogEntry.create!(:target_id => attachment.id, :user_id => current_user.id, :course => attachment.course)
	end
end

class AttachmentEditLogEntry < AttachmentLogEntry; end
class AttachmentCreateLogEntry < AttachmentLogEntry; end
class AttachmentRestoreLogEntry < AttachmentLogEntry; end
