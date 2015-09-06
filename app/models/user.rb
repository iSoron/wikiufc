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
  acts_as_paranoid

  has_and_belongs_to_many :courses, order: 'full_name',
                                    conditions: "period = '#{App.current_period}'"

  validates_length_of :login, within: 3..40
  validates_length_of :name, within: 3..40
  validates_length_of :display_name, within: 3..40

  validates_presence_of :login, :email, :display_name
  validates_uniqueness_of :login, :email, :display_name

  validates_format_of :login, with: /^[^0-9]/
  validates_format_of :display_name, with: /^[^0-9]/

  validates_format_of :email,
                      with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

  attr_protected :id, :salt
  attr_accessor :password, :password_confirmation

  def self.find_by_login_and_pass(login, pass)
    user = find(:first, conditions: ['login = ?', login])
    (!user.nil? && User.encrypt(pass, user.salt) == user.hashed_password) ? user : nil
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(indent: options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.user do
      xml.id id
      xml.name name
      xml.display_name display_name
      xml.login login
      xml.created_at created_at
      xml.last_seen last_seen
      xml.description description
    end
  end

  # Gera uma nova senha, e a envia por email.
  def generate_password_reset_key!
    update_attribute(:password_reset_key, User.random_string(30))
    save!
    Notifications.deliver_forgot_password(email, password_reset_key)
  end

  def reset_login_key
    self.login_key = Digest::SHA1.hexdigest(Time.now.to_s + password.to_s +
        rand(123_456_789).to_s).to_s
  end

  def reset_login_key!
    reset_login_key
    save!
    login_key
  end

  def to_param
    login.match(/^[-_a-z0-9]*$/i).nil? ? id.to_s : login
  end

  def courses_not_enrolled(period)
    if courses.empty?
      Course.visible.where(period: period)
    else
      Course.where('period = ? and hidden = ? and id not in (?)',
                   period, false, courses)
    end
  end

  protected

  def validate
    if new_record?
      errors.add_on_blank :password
      errors.add_on_blank :password_confirmation
    end

    return unless @password.blank?
    errors.add(:password_confirmation) if @password_confirmation.blank? ||
                                          @password != @password_confirmation
    errors.add(:password, 'é muito curta') unless @password.length >= 5
  end

  def before_save
    self.salt = User.random_string(10) unless self.salt?
    self.secret = User.random_string(32) unless self.secret?
    self.hashed_password = User.encrypt(@password, salt) unless @password.blank?
  end

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass + salt)
  end

  def self.random_string(len)
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    newpass = ''
    1.upto(len) { |_i| newpass << chars[rand(chars.size - 1)] }
    newpass
  end
end
