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

class CourseTest < ActiveSupport::TestCase
  fixtures :courses

  def test_related_courses
    course = courses(:course_1)
    related = courses(:related_course)
    assert course.related_courses.include?(related)
  end

  def test_initial_wiki_pages
    Course.create!(short_name: 'course999', description: '', code: 123,
                   full_name: 'Course 999', grade: 1, hidden: false,
                   period: '2000.1')
    course = Course.find_by_short_name('course999')
    assert course.wiki_pages.length == App.initial_wiki_pages.length
  end

  def test_to_param
    current_course = courses(:course_1)
    old_course = courses(:related_course)
    assert current_course.to_param == current_course.short_name
    assert old_course.to_param == old_course.id.to_s
  end

  def test_recent_news
    course = courses(:related_course)
    user = User.first

    assert course.news.length == 0

    news = course.news.create!(title: 'hello', body: 'hello',
                               timestamp: 1.hour.ago, sender_id: user.id,
                               receiver_id: course.id, version: 1)
    assert course.recent_news.include?(news)

    news = course.news.create!(title: 'hello', body: 'hello',
                               timestamp: 1.month.ago, sender_id: user.id,
                               receiver_id: course.id, version: 1)
    assert !course.recent_news.include?(news)
  end
end
