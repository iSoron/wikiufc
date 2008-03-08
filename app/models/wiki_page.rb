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

	belongs_to :course
	belongs_to :user

	generate_validations
	validates_uniqueness_of :title, :scope => :course_id
	validates_format_of :title, :with => /^[^0-9]/

	acts_as_paranoid
	acts_as_list :scope => 'course_id = #{course_id}'
	acts_as_versioned :if_changed => [ :content, :description, :title ]
	self.non_versioned_fields << 'position'

	def to_html(text = self.content)
		return BlueCloth.new(text).to_html
	end

	def to_param
		self.title
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
