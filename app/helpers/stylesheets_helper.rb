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

module StylesheetsHelper

	def browser_is? name
		name = name.to_s.strip
		return true if browser_name == name
		return true if name == 'mozilla' && browser_name == 'gecko'
		return true if name == 'ie' && browser_name.index('ie')
		return true if name == 'webkit' && browser_name == 'safari'

	end

	def browser_name
		@browser_name ||= begin
			ua = request.env['HTTP_USER_AGENT'].downcase
			if ua.index('msie') && !ua.index('opera') && !ua.index('webtv')
				'ie'+ua[ua.index('msie')+5].chr
			elsif ua.index('gecko/')
				'gecko'
			elsif ua.index('opera')
				'opera'
			elsif ua.index('konqueror')
				'konqueror'
			elsif ua.index('applewebkit/')
				'safari'
			elsif ua.index('mozilla/')
				'gecko'
			end
		end
	end

	def ie?
		return browser_is?('ie')
	end
end
