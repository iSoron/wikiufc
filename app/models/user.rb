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

require 'digest/sha1'

class User < ActiveRecord::Base

	# Plugins
	acts_as_paranoid

	# Associacoes
	has_and_belongs_to_many :courses, :order => 'full_name', :conditions => "period = #{App.current_period}"

	# Validacao
	validates_length_of       :login, :within => 3..40
	validates_length_of       :name,  :within => 3..40
	validates_length_of       :display_name, :within => 3..40

	validates_presence_of     :login, :email, :display_name
	validates_uniqueness_of   :login, :email, :display_name

	validates_format_of :login, :with => /^[^0-9]/
	validates_format_of :display_name, :with => /^[^0-9]/

	validates_format_of :email,
			:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

	# Seguranca
	attr_protected :id, :salt
	attr_accessor :password, :password_confirmation

	def User.find_by_login_and_pass(login, pass)
		user = find(:first, :conditions => [ "login = ?", login ])
		return (!user.nil? and User.encrypt(pass, user.salt) == user.hashed_password) ? user : nil
	end

	def to_xml(options = {})
		options[:indent] ||= 2
		xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
		xml.instruct! unless options[:skip_instruct]
		xml.user do
			xml.id self.id
			xml.name self.name
			xml.display_name self.display_name
			xml.login self.login
			xml.created_at self.created_at
			xml.last_seen self.last_seen
			xml.description self.description
		end
	end

	# Gera uma nova senha, e a envia por email.
	def generate_password_reset_key!
		update_attribute(:password_reset_key, User.random_string(30))
		save!
		Notifications.deliver_forgot_password(self.email, self.password_reset_key)
	end

	def reset_login_key
		self.login_key = Digest::SHA1.hexdigest(Time.now.to_s + password.to_s + rand(123456789).to_s).to_s
	end

	def reset_login_key!
		reset_login_key
		save!
		self.login_key
	end

	def to_param
		self.login.match(/^[-_a-z0-9]*$/i).nil? ? self.id.to_s : self.login
	end

	protected
	def validate
		if new_record?
			errors.add_on_blank :password
			errors.add_on_blank :password_confirmation
		end

		if !@password.blank?
			errors.add(:password_confirmation) if @password_confirmation.blank? or @password != @password_confirmation
			errors.add(:password, 'é muito curta') if !(5..40).include?(@password.length)
		end
	end

	def before_save
		self.salt = User.random_string(10) if !self.salt?
		self.secret = User.random_string(32) if !self.secret?
		self.hashed_password = User.encrypt(@password, self.salt) if !@password.blank?
	end

	def self.encrypt(pass, salt)
		Digest::SHA1.hexdigest(pass + salt)
	end

	def self.random_string(len)
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		newpass = ""
		1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
		return newpass
	end

end
