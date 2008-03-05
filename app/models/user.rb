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

require 'digest/sha1'

class User < ActiveRecord::Base

	has_and_belongs_to_many :courses, :order => 'full_name'

	validates_length_of       :login, :within => 3..40
	validates_length_of       :name,  :within => 3..40
	validates_length_of       :display_name, :within => 3..40

	validates_presence_of     :login, :email, :display_name
	validates_uniqueness_of   :login, :email, :display_name

	validates_format_of :display_name, :with => /^[^0-9]/
	validates_format_of :email,
			:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

	attr_protected :id, :salt
	attr_accessor :password, :password_confirmation

	has_many :shoutbox_messages,
			 :class_name => 'UserShoutboxMessage',
			 :foreign_key => "receiver_id",
			 :order => 'id desc'

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
	def send_new_password
		new_pass = User.random_string(10)
		@password = @password_confirmation = new_pass
		save
		Notifications.deliver_forgot_password(self.email, self.login, new_pass)
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
		self.login
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
