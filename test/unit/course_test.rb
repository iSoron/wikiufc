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

require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < Test::Unit::TestCase

	fixtures :courses

	def test_orphaned_records
		# Escolhe um curso qualquer
		course = courses(:course_1)

		# Cria alguns objetos associados ao curso
		attachment = Attachment.create(:file_name => 'test', :content_type => 'text/plain',
				:last_modified => Time.now, :description => 'test', :size => 1.megabyte,
				:course_id => course.id)
	
		wiki_page = WikiPage.create(:title => 'teste', :course_id => course.id)

		shoutbox_message = Message.create(:title => 'test', :body => 'test body',
				:timestamp => Time.now, :type => "CourseShoutboxMessage",
				:sender_id => 0, :receiver_id => course.id)
	
		news_message = Message.create(:title => 'test', :body => 'test body',
				:timestamp => Time.now, :type => "News",
				:sender_id => 0, :receiver_id => course.id)
		
		event = Event.create(:title => 'test', :time => Time.now,
				:created_by => 0, :course_id => course.id, :description => 'test')

		# Deleta o curso
		course.destroy

		# Ve o que aconteceu com os objetos
		assert_raises(ActiveRecord::RecordNotFound) { Attachment.find(attachment.id) }
		assert_raises(ActiveRecord::RecordNotFound) { WikiPage.find(wiki_page.id) }
		assert_raises(ActiveRecord::RecordNotFound) { CourseShoutboxMessage.find(shoutbox_message.id) }
		assert_raises(ActiveRecord::RecordNotFound) { News.find(news_message.id) }
		assert_raises(ActiveRecord::RecordNotFound) { Event.find(event.id) }
	end
end
