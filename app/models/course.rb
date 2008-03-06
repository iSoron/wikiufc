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

class Course < ActiveRecord::Base

	# Associacoes
	has_many :attachments,
	         :order => "file_name",
	          :dependent => :destroy

	has_many :events,
	         :order => "time asc",
	         :dependent => :destroy

	has_many :news,
	         :foreign_key => "receiver_id",
	        :order => "id desc",
	        :dependent => :destroy

	has_many :log_entries,
	         :order => "created_at desc",
	         :dependent => :destroy

	has_many :wiki_pages,
	         :order => "position",
	         :dependent => :destroy

	# Plugins
	acts_as_paranoid

	# Validacao
	generate_validations
	validates_uniqueness_of :short_name
	validates_format_of :short_name, :with => /^[^0-9]/
	
	def after_create
		App.inital_wiki_pages.each do |page_title|
			wiki_page = WikiPage.new(:title => page_title, :version => 1, :content => App.initial_wiki_page_content)
			self.wiki_pages << wiki_page
		end
	end

	def to_param
		self.short_name
	end
end
