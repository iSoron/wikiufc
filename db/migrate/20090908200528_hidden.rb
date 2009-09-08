class Hidden < ActiveRecord::Migration
	def self.up
		add_column :courses, :hidden, :boolean, :null => false, :default => false
		add_column :wiki_pages, :front_page, :boolean, :null => false, :default => true
		add_column :attachments, :front_page, :boolean, :null => false, :default => true
	end

	def self.down
		remove_column :courses, :hidden
		remove_column :wiki_pages, :front_page
		remove_column :attachments, :front_page
	end
end
