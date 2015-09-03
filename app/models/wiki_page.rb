# -*- encoding : utf-8 -*-
# Wiki UFC
# Copyright (C) 2007, Adriano, Alinson, Andre, Rafael e Bustamante
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
  attr_writer :type

  # Plugins
  acts_as_paranoid
  acts_as_list :scope => 'course_id = #{course_id}'
  acts_as_versioned :if_changed => [:content, :description, :title]
  self.non_versioned_columns << 'front_page'
  self.non_versioned_columns << 'position'
  self.non_versioned_columns << 'deleted_at'
  self.non_versioned_columns << 'canonical_title'

  # Associacoes
  belongs_to :course
  belongs_to :user, :with_deleted => true

  # Valicacao
  validates_presence_of :front_page
  validates_presence_of :description
  validates_presence_of :title
  validates_presence_of :content
  validates_uniqueness_of :title, :scope => :course_id
  validates_uniqueness_of :canonical_title, :scope => :course_id
  validates_format_of :title, :with => /^[^0-9]/

  before_validation :set_canonical_title
  before_save :set_position

  # acts_as_paranoid_versioned
  self.versioned_class.class_eval do
    def self.delete_all(conditions = nil)
      return
    end
  end

  def set_canonical_title
    self.canonical_title = self.title.pretty_url
  end

  def set_position
    if !self.front_page
      self.remove_from_list
    elsif self.position.nil?
      self.update_attribute(:position, (self.course.wiki_pages.maximum(:position)||0) + 1)
    end
  end

  def validate
    begin
      self.content.format_wiki
    rescue
      errors.add("content", "possui erro de sintaxe: " + $!.to_s.html_escape)
    end
  end

  def to_param
    self.canonical_title
  end

  def self.find_front_page
    WikiPage.all(:conditions => ["front_page = ?", true])
  end

  def WikiPage.diff(from, to)
    # Cria um arquivo com o conteudo da versao antiga
    original_content_file = Tempfile.new("old")
    original_content_file << from.content << "\n"
    original_content_file.flush

    # Cria um arquivo com o conteudo da versao nova
    new_content_file = Tempfile.new("new")
    new_content_file << to.content << "\n"
    new_content_file.flush

    # Calcula as diferencas
    diff = `diff -u #{original_content_file.path()} #{new_content_file.path()}`

    # Fecha os arquivos temporarios
    new_content_file.close!
    original_content_file.close!

    return diff
  end
end
