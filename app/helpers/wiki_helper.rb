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
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

    out = dup
    out = out.gsub('\\', '\\\\\\')
    out, inline_math = out.extract_blocks(/({\$((?!\$}).)*\$})/m, 'INLINEMATH')
    out, block_math = out.extract_blocks(/({\$\$((?!\$\$}).)*\$\$})/m,
                                         'BLOCKMATH')
    out = markdown.render(out)

    out = out.reinsert_blocks(block_math, 'BLOCKMATH')
    out = out.reinsert_blocks(inline_math, 'INLINEMATH')

    sanitize out
  end

  def extract_blocks(regexp, prefix)
    matches = []
    modified = gsub(regexp) do |m|
      matches << m
      "#{prefix}#{matches.length - 1}#{prefix}"
    end
    return modified, matches
  end

  def reinsert_blocks(blocks, prefix)
    modified = dup
    blocks.each_with_index do |block, idx|
      modified.gsub!("#{prefix}#{idx}#{prefix}", block)
    end
    modified
  end
end

module WikiHelper
  def format_diff(text)
    last = 0
    result = ""
    text << "\n"
    style = { '+' => 'add', '-' => 'del', ' ' => 'line' }

    text.each_line do |line|
      next if line.match(/^---/)
      next if line.match(/^\+\+\+/)

      if line[0].chr == '@'
        result << "<tr><td class='diff_space diff_border_#{style[last.chr]}' ></td></tr>"
        last = 0
      else
        if line[0] != last
          last = line[0] if last == 0 || line[0].chr == '+' || line[0].chr == '-'
          result << "<tr><td class='diff_border_#{style[last.chr]} "
          last = line[0]
        else
          result << "<tr><td class='"
        end
        result << "diff_#{style[line[0].chr]}'>" \
            " #{line[1..-1]}&nbsp;</td></td>"
      end
    end

    "<table class='diff'>#{result}</table>"
  end
end
