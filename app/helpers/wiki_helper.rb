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

class String
	include ActionView::Helpers::SanitizeHelper
	def format_wiki
		text = BlueCloth.new(self).to_html
		text = Hpricot(text, :xhtml_strict => true).to_s
		return sanitize text
	end
end

module WikiHelper

	def format_diff(text)
		last = 0
		result = ""
		text << "\n"
		style = { '+' => 'add', '-' => 'del', ' ' => 'line' }

		text.each_line do |line|
			# Ignora o cabecalho
			next if line.match(/^---/)
			next if line.match(/^\+\+\+/)

			# Divisao entre pedacos
			if line[0].chr == '@'
				result << "<tr><td class='diff_space diff_border_#{style[last.chr]}' ></td></tr>"
				last = 0
			else
				# Verifica se mudou de contexto (add para del, linha normal para add, etc)
				if line[0] != last
					last = line[0] if last == 0 or line[0].chr == '+' or line[0].chr == '-'
					result << "<tr><td class='diff_border_#{style[last.chr]} "
					last = line[0]

				else
					result << "<tr><td class='"
				end
				result << "diff_#{style[line[0].chr]}'>" +
						" #{line[1..-1]}&nbsp;</td></td>"
			end
		end

		return "<table class='diff'>#{result}</table>"
	end
end
