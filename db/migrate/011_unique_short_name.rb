class UniqueShortName < ActiveRecord::Migration
	def self.up
		add_index :courses, :short_name, :unique => true
	end

	def self.down
		remove_index :courses, :short_name
	end
end
