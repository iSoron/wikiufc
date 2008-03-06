class MoreParanoid < ActiveRecord::Migration
	def self.up
		add_column :courses, :deleted_at, :datetime
		add_column :log_entries, :deleted_at, :datetime
		add_column :users, :deleted_at, :datetime
	end

	def self.down
		add_column :courses, :deleted_at
		add_column :log_entries, :deleted_at
		add_column :users, :deleted_at
	end
end
