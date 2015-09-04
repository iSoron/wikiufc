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

module AttachmentsHelper

	def attachments_to_nested_hash(atts)
		paths = atts.collect { |item| item.path.nil? ? [] : item.path.split("/") }
		return nest_path(atts, paths, 0, paths.size-1, 0)
	end

	def nest_path(items, paths, from, to, level)
		result = { }

		base = from - 1
		base = base + 1 while base+1 <= to and paths[base+1][level].nil?
		if base >= from then
			result['/'] = items[from..base]
		end

		start = base+1

		return result if start > to

		folder = paths[start][level]
		(base+1).upto(to) do |i|
			if paths[i][level] != folder
				result[folder] = nest_path(items, paths, start, i-1, level+1)
				start = i
				folder = paths[i][level]
			end
		end

		if start <= to then
			result[folder] = nest_path(items, paths, start, to, level+1)
		end

		return result
	end

	def nested_attachments_to_html(atts, level=0)
		out = (level > 0 ? "<ul class='nested' style='display: none'>" : "<ul>")
		keys = atts.keys.sort

		for att in atts['/'] do
			out = out + "<li class='#{mime_class(att.content_type)}'>#{link_to h(att.file_name), course_attachment_url(@course, att)}</li>"
		end if atts['/']

		for key in keys - ['/'] do
			out = out + "<li class='mime_folder' onclick='this.next().toggle(); return false;'>#{link_to h(key), '#'}&nbsp;</li>"
			out = out + nested_attachments_to_html(atts[key], level+1)
		end

		out = out + "</ul>"
	end

end
