class MoreParanoid < ActiveRecord::Migration
	def self.up
		add_column :courses, :deleted_at, :datetime
		add_column :log_entries, :deleted_at, :datetime
		add_column :users, :deleted_at, :datetime
	end

	def self.down
		remove_column :courses, :deleted_at
		remove_column :log_entries, :deleted_at
		remove_column :users, :deleted_at
	end
end
