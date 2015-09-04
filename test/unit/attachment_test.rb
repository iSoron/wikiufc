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

#require File.dirname(__FILE__) + '/../test_helper'
#
#class AttachmentTest < ActiveSupport::TestCase
#	fixtures :attachments
#
#	def setup
#		# Cria um pseudo-arquivo, com conteudo qualquer
#		@test_file = StringIO.new
#		@test_file.puts("temp" * 10)
#		@test_file.rewind
#	end
#
#	def test_create_and_destroy_attachment
#		# Cria o anexo
#		att = Attachment.new(:file_name => 'test_file', :content_type => 'text/plain',
#				:description => 'A test file', :course_id => 1)
#		att.file = @test_file
#
#		# Verifica gravacao no bando de dados
#		assert att.save
#
#		# Verifica se o arquivo foi criado no sistema de arquivos
#		file_path = "#{RAILS_ROOT}/public/upload/1/#{att.id}"
#		assert_equal @test_file.size, att.size
#		assert File.exists?(file_path)
#
#		# Verifica se o conteudo do arquivo gerado eh igual ao conteudo do
#		# arquivo original
#		@test_file.rewind
#		assert_equal @test_file.read, File.open(file_path, "r").read
#
#		# Deleta o anexo
#		#att.destroy
#
#		# Verifica se o arquivo foi excluido
#		#assert !File.exists?(file_path)
#	end
#end
#
