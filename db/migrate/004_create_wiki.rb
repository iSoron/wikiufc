class CreateWiki < ActiveRecord::Migration
	def self.up
		create_table :wiki_pages do |t|
			t.column :course_id, :int
			t.column :title, :string, :null => false
		end

		create_table :wiki_versions do |t|
			t.column :cache_html, :text
			t.column :content, :text, :null => false
			t.column :created_on, :timestamp, :null => false
			t.column :user_id, :int
			t.column :wiki_page_id, :int
		end
	end

	def self.down
		drop_table :wiki_pages
		drop_table :wiki_versions
	end
end
