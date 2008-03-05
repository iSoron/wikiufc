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

class WikiPageTest < Test::Unit::TestCase

	def test_should_create_new_version_when_editing
		wp = WikiPage.create(:content => 'test', :title => 'test', :version => 1, :course_id => 1, :user_id => 1, :description => 'teste')
		assert !wp.save_version?

		wp.content = 'new content'
		assert wp.save_version?
	end

	def test_should_not_create_new_version_when_reordering
		wp = WikiPage.create(:content => 'test', :title => 'test', :version => 1, :course_id => 1, :user_id => 1, :description => 'teste')
		assert !wp.save_version?

		wp.move_higher
		assert !wp.save_version?
	end
end
