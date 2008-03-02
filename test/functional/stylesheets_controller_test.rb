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
require 'stylesheets_controller'

# Re-raise errors caught by the controller.
class StylesheetsController; def rescue_action(e) raise e end; end

class StylesheetsControllerTest < Test::Unit::TestCase

	def setup
		@controller = StylesheetsController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	# Replace this with your real tests.
	def test_truth
		assert true
	end

end
