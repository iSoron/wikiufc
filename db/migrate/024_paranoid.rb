class Paranoid < ActiveRecord::Migration
	def self.up
		add_column :wiki_pages, :deleted_at, :timestamp
		add_column :messages, :deleted_at, :timestamp
		add_column :events, :deleted_at, :timestamp
		add_column :attachments, :deleted_at, :timestamp
	end

	def self.down
		remove_column :wiki_pages, :deleted_at
		remove_column :messages, :deleted_at
		remove_column :events, :deleted_at
		remove_column :attachments, :deleted_at
	end
end
