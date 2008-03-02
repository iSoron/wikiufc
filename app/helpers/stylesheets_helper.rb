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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.

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
