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

class MessageSender < ActiveRecord::Migration
	def self.up
		add_column :messages, :sender_id, :int, :null => false
		add_column :users, :name, :string, :null => false, :default => ''
	end

	def self.down
		remove_column :messages, :sender_id
		remove_column :users, :name
	end
end
