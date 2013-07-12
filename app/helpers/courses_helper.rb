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

module CoursesHelper
	def mime_class(str)
		str.strip!
		case str
			when "application/octet-stream"
				return "mime_binary"

			when
				"application/pdf",
				"application/postscript",
				"application/msword"
				return "mime_document"
			
			when "application/pdf"
				return "mime_document"

			when
				"application/zip",
				"application/x-gzip",
				"application/x-gtar"
				return "mime_zip"

			else "mime_plain_text"
		end
	end
end
