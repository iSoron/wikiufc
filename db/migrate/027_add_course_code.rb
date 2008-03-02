class AddCourseCode < ActiveRecord::Migration
	def self.up
		add_column :courses, :code, :string, :null => false, :default => "CK000"
		add_column :courses, :period, :integer, :null => false, :default => 1
	end

	def self.down
		remove_column :courses, :code
		remove_column :courses, :period
	end
end
