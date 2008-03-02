class CreateLogEntries < ActiveRecord::Migration
	def self.up
		create_table :log_entries do |t|
			t.datetime :created_at
			t.integer :course_id, :null => false
			t.integer :user_id, :null => false
			t.integer :version
			t.integer :target_id
			t.string :type
		end
	end

	def self.down
		drop_table :log_entries
	end
end
