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
