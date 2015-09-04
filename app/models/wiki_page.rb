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

require 'acts_as_versioned'
require 'tempfile'

class WikiPage < ActiveRecord::Base
  attr_accessible :title, :front_page, :content, :description

  scope :hidden, where(front_page: false)

  acts_as_paranoid
  acts_as_list scope: 'course_id = #{course_id}'
  acts_as_versioned if_changed: [:content, :description, :title]
  non_versioned_columns << 'front_page'
  non_versioned_columns << 'position'
  non_versioned_columns << 'deleted_at'
  non_versioned_columns << 'canonical_title'

  belongs_to :course
  belongs_to :user, with_deleted: true

  validates_presence_of :description
  validates_presence_of :title
  validates_presence_of :content
  validates_uniqueness_of :title, scope: :course_id
  validates_uniqueness_of :canonical_title, scope: :course_id
  validates_format_of :title, with: /^[^0-9]/

  before_validation :set_canonical_title
  before_save :set_position

  # acts_as_paranoid_versioned
  versioned_class.class_eval do
    def self.delete_all(_conditions = nil)
      nil
    end
  end

  def set_canonical_title
    self.canonical_title = title.pretty_url
  end

  def set_position
    if !front_page
      remove_from_list
    elsif position.nil?
      max_position = (course.wiki_pages.maximum(:position) || 0)
      update_attribute(:position, max_position + 1)
    end
  end

  def validate
    content.format_wiki
  rescue
    errors.add("content", "possui erro de sintaxe: " +
               $ERROR_INFO.to_s.html_escape)
  end

  def to_param
    canonical_title || id
  end

  def self.from_param(param)
    if param.is_numeric?
      WikiPage.find!(param)
    else
      WikiPage.find_by_canonical_title!(param)
    end
  end

  def self.find_front_page
    WikiPage.all(conditions: ["front_page = ?", true])
  end

  def self.diff(from, to)
    original_content_file = Tempfile.new("old")
    original_content_file << from.content << "\n"
    original_content_file.flush

    new_content_file = Tempfile.new("new")
    new_content_file << to.content << "\n"
    new_content_file.flush

    diff = `diff -u #{original_content_file.path} #{new_content_file.path}`

    new_content_file.close!
    original_content_file.close!

    diff
  end
end
