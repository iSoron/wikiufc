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

class AttachmentLogEntry < LogEntry
	def attachment
		Attachment.find_with_deleted(target_id)
	end
end

class AttachmentDeleteLogEntry < AttachmentLogEntry
	def reversible?()
		a = Attachment.find_with_deleted(target_id)
		a.deleted_at != nil
	end
	def undo!(current_user)
		a = Attachment.find_with_deleted(target_id)
		a.update_attribute(:deleted_at, nil)
		AttachmentRestoreLogEntry.create!(:target_id => a.id, :user_id => current_user.id,
				:course => a.course)
	end
end

class AttachmentEditLogEntry < AttachmentLogEntry; end
class AttachmentCreateLogEntry < AttachmentLogEntry; end
class AttachmentRestoreLogEntry < AttachmentLogEntry; end
