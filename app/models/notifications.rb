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

class Notifications < ActionMailer::Base

	def forgot_password(to, login, pass, sent_at = Time.now)
		@subject = "Your password is ..."
		@body['login']=login
		@body['pass']=pass
		@recipients = to
		@from = 'support@yourdomain.com'
		@sent_on = sent_at
		@headers = {}
	end
end
