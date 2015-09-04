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

class EventLogEntry < LogEntry
  belongs_to :event,
      :foreign_key => "target_id",
      :with_deleted => true
end

class EventDeleteLogEntry < EventLogEntry
  def reversible?()
    event.deleted?
  end

  def undo!(current_user)
    event.recover!
    EventRestoreLogEntry.create!(:target_id => event.id, :user_id => current_user.id, :course => event.course, :version => event.version)
  end
end

class EventEditLogEntry < EventLogEntry
end

class EventCreateLogEntry < EventLogEntry
end

class EventRestoreLogEntry < EventLogEntry
end
