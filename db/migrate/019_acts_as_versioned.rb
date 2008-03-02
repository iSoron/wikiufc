class ActsAsVersioned < ActiveRecord::Migration
	def self.up
		drop_table :wiki_pages
		drop_table :wiki_versions

		create_table :wiki_pages, :force => true do |t|
			t.integer :course_id
			t.integer :user_id
			t.integer :version, :null => false
			t.string :description
			t.string :title
			t.text :content, :null => false
			t.timestamps
		end

		WikiPage.create_versioned_table
	end

	def self.down
		WikiPage.drop_versioned_table
		create_table "wiki_pages", :force => true do |t|
			t.integer "course_id"
			t.string  "title",                         :null => false
			t.integer "diff_countdown", :default => 0, :null => false
		end

		create_table "wiki_versions", :force => true do |t|
			t.text     "content",                        :null => false
			t.datetime "created_on",                     :null => false
			t.integer  "user_id"
			t.integer  "wiki_page_id"
			t.boolean  "root",         :default => true, :null => false
			t.text     "description"
		end
	end
end
