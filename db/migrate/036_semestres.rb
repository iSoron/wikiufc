class Semestres < ActiveRecord::Migration
	def self.up
		rename_column :courses, :period, :grade
		add_column :courses, :period, :string
		Course.find(:all).each do |c|
			c.update_attribute(:period, "2008.1")
		end

		remove_index :courses, :short_name
		add_index :courses, :short_name, :unique => false
	end

	def self.down
		remove_column :courses, :period
		rename_column :courses, :grade, :period
		remove_index :courses, :short_name
		add_index :courses, :short_name, :unique => true
	end
end
