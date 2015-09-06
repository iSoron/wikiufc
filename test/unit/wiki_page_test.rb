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

require File.dirname(__FILE__) + '/../test_helper'

class WikiPageTest < ActiveSupport::TestCase

  context "wiki engine" do
    should "handle non-ASCII characters properly" do
      assert "áá**aa**".format_wiki =~ %r{<p>áá<strong>aa</strong></p>}
    end
  end

	# should "not delete versions on destroy" do
	# 	wp = WikiPage.new(:course_id => 1, :user_id => 1, :title => "t", :content => "c", :description => "d", :version => 1)
	# 	wp.save!
	# 	wp.destroy

	# 	wp = WikiPage.find_with_deleted(wp.id)
	# 	wp.recover!
	# 	assert !wp.versions.empty?
	# end

	# def test_should_create_new_version_when_editing
	# 	wp = WikiPage.new
	# 	assert !wp.save_version?

	# 	wp.content = 'new content'
	# 	assert wp.save_version?
	# end

	# def test_should_not_create_new_version_when_reordering
	# 	wp = WikiPage.new
	# 	assert !wp.save_version?

	# 	wp.move_higher
	# 	assert !wp.save_version?
	# end
end
