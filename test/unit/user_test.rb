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

require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

	fixtures :users

	def test_login
		assert_equal  users(:bob), User.find_by_login_and_pass("bob", "test")
		assert_nil User.find_by_login_and_pass("wrong_bob", "test")
		assert_nil User.find_by_login_and_pass("bob", "wrongpass")
		assert_nil User.find_by_login_and_pass("wrong_bob", "wrongpass")
	end


	def test_change_password
		user = users(:longbob)

		# Check success
		assert_equal user, User.find_by_login_and_pass("longbob", "longtest")

		# Change password
		user.password = user.password_confirmation = "nonbobpasswd"
		assert user.save, user.errors.full_messages

		# New password works
		assert_equal user, User.find_by_login_and_pass("longbob", "nonbobpasswd")

		# Old pasword doesn't work anymore
		assert_nil User.find_by_login_and_pass("longbob", "longtest")

		# Change back again
		user.password = user.password_confirmation = "longtest"

		assert user.save
		assert_equal user, User.find_by_login_and_pass("longbob", "longtest")
		assert_nil User.find_by_login_and_pass("longbob", "nonbobpasswd")
	end


	def test_keep_old_password
		# Dont change the password
		user = users(:longbob)
		user.name = "brand new bob"

		assert user.save
		assert_equal user, User.find_by_login_and_pass("longbob", "longtest")
		assert_nil User.find_by_login_and_pass("longbob", "")
	
		# Set a blank password
		user.password = user.password_confirmation = ""

		assert user.save
		assert_equal user, User.find_by_login_and_pass("longbob", "longtest")
		assert_nil User.find_by_login_and_pass("longbob", "")
	end


	def test_validate_password_confirmation
		u = users(:longbob)

		# No confirmation
		u.password = "hello"
		assert !u.valid?
		assert u.errors.invalid?('password_confirmation')
		
		# Wrong confirmation
		u.password_confirmation = "wrong hello"
		assert !u.valid?
		assert u.errors.invalid?('password_confirmation')

		# Valid confirmation
		u.password = u.password_confirmation = "hello world"
		assert u.valid?
	end


	def test_validate_password
		u = users(:bob)
		u.login = "anotherbob"
		u.email = "anotherbob@bob.com"

		# Too short
		u.password = u.password_confirmation = "tiny"
		assert !u.valid?
		assert u.errors.invalid?('password')

		# Too long
		u.password = u.password_confirmation = "huge" * 50
		assert !u.valid?
		assert u.errors.invalid?('password')

		# Empty
		newbob = User.new(:login => 'newbob', :email => 'bob@bob.com', :name => 'bob')
		newbob.password = newbob.password_confirmation = ""
		assert !newbob.valid?
		assert newbob.errors.invalid?('password')

		# OK
		u.password = u.password_confirmation = "bobs_secure_password"
		assert u.save, u.errors.full_messages
		assert u.errors.empty?
	end


	def test_validate_login
		u = users(:bob)
		u.password = u.password_confirmation = "bobs_secure_password"
		u.email = "okbob@mcbob.com"

		# Too short
		u.login = "x"
		assert !u.valid?
		assert u.errors.invalid?('login')
		assert_equal 1, u.errors.count, u.errors.full_messages

		# Too long
		u.login = "hugebob" * 50
		assert !u.valid?
		assert u.errors.invalid?('login')
		assert_equal 1, u.errors.count, u.errors.full_messages

		# Empty
		u.login = ""
		assert !u.valid?
		assert u.errors.invalid?('login')
		assert_equal 3, u.errors.count, u.errors.full_messages

		# OK
		u.login = "okbob"
		assert u.valid?
		assert u.errors.empty?
	end


	def test_validate_email
		u = users(:longbob)

		# No email
		u.email = nil
		assert !u.valid?
		assert u.errors.invalid?('email')
		assert_equal 2, u.errors.count, u.errors.full_messages

		# Invalid email
		u.email='notavalidemail'
		assert !u.valid?
		assert u.errors.invalid?('email')
		assert_equal 1, u.errors.count, u.errors.full_messages

		# OK
		u.email="validbob@mcbob.com"
		assert u.valid?
		assert u.errors.empty?
	end

	def test_signup
		u = User.new
		u.last_seen = Time.now
		u.login = "new bob"
		u.display_name = "new bob"
		u.name = u.email = "new@email.com"
		u.password = u.password_confirmation = "new password"

		assert u.save, u.errors.full_messages
		assert_equal u, User.find_by_login_and_pass(u.login, u.password)

		assert_not_nil u.salt
		assert_equal 10, u.salt.length
	end

#	def test_send_new_password
#		#check user find_by_login_and_passs
#		assert_equal  @bob, User.find_by_login_and_pass("bob", "test")
#
#		#send new password
#		sent = @bob.send_new_password
#		assert_not_nil sent
#
#		#old password no longer workd
#		assert_nil User.find_by_login_and_pass("bob", "test")
#
#		#email sent...
#		assert_equal "Your password is ...", sent.subject
#
#		#... to bob
#		assert_equal @bob.email, sent.to[0]
#		#assert_match Regexp.new("Your username is bob."), sent.body
#
#		#can find_by_login_and_pass with the new password
#		#new_pass = $1 if Regexp.new("Your new password is (\\w+).") =~ sent.body
#		#assert_not_nil new_pass
#		#assert_equal  @bob, User.find_by_login_and_pass("bob", new_pass)
#	end

	def test_generate_random_pass
		new_pass = User.random_string(10)
		assert_not_nil new_pass
		assert_equal 10, new_pass.length
	end


	def test_sha1
		u = users(:bob)
		u.password = u.password_confirmation = "bobs_secure_password"

		assert u.save
		assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', u.hashed_password
		assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', User.encrypt("bobs_secure_password", u.salt)
	end


	def test_protected_attributes
		u = users(:bob)
		u.update_attributes(:id => 999999, :salt => "I-want-to-set-my-salt", :login => "verybadbob")

		assert u.save
		assert_not_equal 999999, u.id
		assert_not_equal "I-want-to-set-my-salt", u.salt
		assert_equal "verybadbob", u.login
	end
end
