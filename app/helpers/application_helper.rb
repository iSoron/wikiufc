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

require 'digest/md5'

module ApplicationHelper

	# Converte para o timezone local
	def tz(time_at)
		TzTime.zone.utc_to_local(time_at.utc)
	end

	FLASH_NAMES = [:notice, :warning, :message]	

	def flash_div
		output = ""
		for name in FLASH_NAMES
			if flash[name]
				output << "<div id='validation' class='validation #{name}' style='display: none'>#{flash[name]}"
				output << ". " + link_to("Undo"[] + "?", flash[:undo], :method => 'post') if flash[:undo]
				output << "</div>"
			end
		end
		return output
	end

	def logged_in?
		session[:user_id]
	end

	def current_user
		User.find(session[:user_id]) if logged_in?
	end

	def admin?
		logged_in? and current_user.admin?
	end

	def wiki(text)
		BlueCloth.new(text).to_html
	end

	def highlight(name)
		return {:class => 'highlight'} if (flash[:highlight] == name) 
	end

	def spinner(name)
		return image_tag("loading.gif", :id => "spinner_#{name}", :style => "display:none")
	end

	def gravatar_url_for(email, size=80)
		"http://www.gravatar.com/avatar.php?gravatar_id=#{Digest::MD5.hexdigest(email)}&size=#{size}&default=#{App.default_avatar}"
	end

	def action_icon(action_name, description, options = {}, html_options = {})
		html_options.merge!({:class => 'icon', :alt => description, :title => description})
		link_to(image_tag("action/#{action_name}.gif", :title => description), options, html_options)
	end
end
