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

require 'fileutils.rb'

class Attachment < ActiveRecord::Base

	belongs_to :course
	generate_validations
	acts_as_paranoid

	# Atributo virtual file
	def file=(new_file)
		@tmp_file = new_file
		self.size = new_file.size
	end

	# Limpa o nome do arquivo
	protected
	def sanitize(filename)
		filename = File.basename(filename)
		filename.gsub(/[^\w\.\-]/, '_')
	end

	# Verifica se o arquivo é válido
	def validate
		if @tmp_file
			errors.add("file") if @tmp_file.size == 0
			errors.add("file", "is too large"[]) if @tmp_file.size > App.max_upload_file_size
		else
			# Caso o objeto possua id, significa que ele já está no banco de dados.
			# Um arquivo em branco, entao, não é inválido: significa que a pessoa só quer
			# modificar a descrição, ou algo assim..
			errors.add("file", "is needed"[]) if not self.id
		end
	end

	# Salva o arquivo fisicamente no HD
	def after_save
		@file_path = "#{RAILS_ROOT}/public/upload/#{course.id}/#{self.id}"
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
	#	@file_path = "#{RAILS_ROOT}/public/upload/#{course.id}/#{self.id}"
	#	File.delete(@file_path) if File.exists?(@file_path)
	#end
end
