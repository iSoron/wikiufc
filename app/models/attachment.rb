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

require 'fileutils.rb'

class Attachment < ActiveRecord::Base

	# Plugins
	acts_as_paranoid

	# Associacoes
	belongs_to :course

	# Validacao
	validates_presence_of :file_name
	validates_numericality_of :size, :allow_nil => true, :only_integer => true

	def self.find_front_page
		Attachment.find(:all, :conditions => [ "front_page = ?", true ])
	end

	# Atributo virtual file
	def file=(new_file)
		@tmp_file = new_file
		self.size = new_file.size
		self.content_type ||= "application/octet-stream"
	end

	protected
	def sanitize(filename)
		filename = File.basename(filename)
		filename.gsub(/[^\w\.\-]/, '_')
	end

	def validate
		if @tmp_file
			errors.add("file") if @tmp_file.size == 0
			errors.add("file", I18n.t(:is_too_large)) if @tmp_file.size > App.max_upload_file_size
		else
			# Caso o objeto possua id, significa que ele já está no banco de dados.
			# Um arquivo em branco, entao, não é inválido: significa que a pessoa só quer
			# modificar a descrição, ou algo assim..
			errors.add("file", I18n.t(:is_needed)) if not self.id
		end

		errors.add("path", "muito longo") if !@path.nil? and @path.split('/').size > 10
	end

	# Salva o arquivo fisicamente no HD
	def after_save
		@file_path = "#{Rails.root}/public/upload/#{course.id}/#{self.id}"
		FileUtils.mkdir_p(File.dirname(@file_path))

		if @tmp_file
			logger.debug("Saving #{self.id}")
			File.open(@file_path, "wb") do |f|
				f.write(@tmp_file.read)
			end
		end
	end

	# Deleta o arquivo
	#def after_destroy
	#	@file_path = "#{Rails.root}/public/upload/#{course.id}/#{self.id}"
	#	File.delete(@file_path) if File.exists?(@file_path)
	#end

end
