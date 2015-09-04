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

class Course < ActiveRecord::Base
  acts_as_paranoid

  default_scope order('grade asc, full_name asc, period desc')

  scope :visible, where(hidden: false)

  has_many :attachments,
           order: 'path is not null, path, file_name',
           dependent: :destroy

  has_many :events,
           order: 'time asc',
           dependent: :destroy

  has_many :news,
           foreign_key: 'receiver_id',
           order: 'id desc',
           class_name: 'News',
           dependent: :destroy

  has_many :log_entries,
           order: 'created_at desc',
           dependent: :destroy

  has_many :wiki_pages,
           order: 'position',
           dependent: :destroy

  has_and_belongs_to_many :users,
                          order: 'last_seen desc'

  validates_presence_of :short_name
  validates_presence_of :full_name
  validates_presence_of :code
  validates_numericality_of :grade, only_integer: true
  validates_inclusion_of :hidden, in: [true, false], allow_nil: false
  validates_format_of :short_name, with: /^[^0-9]/

  after_create :add_initial_wiki_pages

  def related_courses
    Course.all(conditions: ['short_name = ?', short_name], limit: 4,
               order: 'period desc')
  end

  def recent_news
    news.all(conditions: ['timestamp > ?', 7.days.ago])
  end

  def add_initial_wiki_pages
    App.initial_wiki_pages.each do |page_title|
      wiki_page = WikiPage.new(title: page_title, description: 'New course',
                               content: App.initial_wiki_page_content)
      wiki_page.user = User.first
      wiki_pages << wiki_page
      wiki_page.save!
    end
  end

  def hidden_wiki_pages?
    wiki_pages.hidden.count > 0
  end

  def to_param
    period == App.current_period ? short_name : id.to_s
  end

  def self.from_param(param)
    param.is_numeric? ? Course.find(param) : Course.find_by_short_name(param)
  end
end
