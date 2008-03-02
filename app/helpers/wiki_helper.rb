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

module WikiHelper

	def format_diff(text)
		last = 0
		result = ""
		text << "\n"
		style = { '+' => 'add', '-' => 'del', ' ' => 'line' }

		text.each do |line|
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
