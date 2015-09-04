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

require 'digest/md5'

module ApplicationHelper
  include CalendarHelper

  # Converte para o timezone local
  def tz(time_at)
    # FIXME
    # TzTime.zone.utc_to_local(time_at.utc)
    time_at
  end

  FLASH_NAMES = [:notice, :warning, :message]

  def flash_div
    output = ""
    for name in FLASH_NAMES
      if flash[name]
        output << "<div id='validation' class='validation #{name}' style='display: none'>#{flash[name]}"
        output << ". " + link_to(t(:undo).capitalize + "?", flash[:undo], method: 'post', accesskey: 'u') if flash[:undo]
        output << "</div>"
      end
    end
    output
  end

  def logged_in?
    session[:user_id]
  end

  def current_user
    User.find(session[:user_id]) if logged_in?
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def formatted(text)
    h(text).gsub("\n", "<br/>")
  end

  def highlight(name)
    return { class: 'highlight' } if (flash[:highlight] == name)
    {}
  end

  def spinner(name)
    image_tag("loading.gif", id: "spinner_#{name}", style: "display:none")
  end

  def markup_enabled_field
    "<p class='grey'>Este campo aceita as linguagens Markdown, Latex e HTML. " +
      link_to('Saiba mais.', '#', id: 'show_markup_help') + spinner('help') + "</p>"
  end

  def markup_help
    "<div id='markup_help' style='display: none'>" +
      File.read("#{Rails.root}/public/static/markup_help.mkd").format_wiki +
      "</div>"
  end

  def gravatar_url_for(email, size = 80)
    "http://www.gravatar.com/avatar.php?gravatar_id=#{Digest::MD5.hexdigest(email)}&size=#{size}&default=#{u(App.default_avatar)}_#{size}.png"
  end

  def action_icon(action_name, description, options = {}, html_options = {})
    html_options.merge!(class: 'icon', alt: description, title: description)
    link_to(image_tag("action/#{action_name}.gif", title: description), options, html_options)
  end

  def format_period(period)
    "20#{period[0..1]}.#{period[2..2]}"
  end
end
