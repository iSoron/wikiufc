class CreateFks < ActiveRecord::Migration
	def self.add_fk(table, fields, reference, cascade = true)
		sql = "alter table #{table} add foreign key (#{fields}) references #{reference}"
		sql = sql + " on update cascade on delete cascade" if cascade
		execute sql
	end

	def self.up
		add_fk :attachments, :course_id, :courses

		add_fk :courses_users, :user_id, :users
		add_fk :courses_users, :course_id, :courses

		add_fk :events, :created_by, :users
		add_fk :events, :course_id, :courses

		add_fk :log_entries, :course_id, :courses
		add_fk :log_entries, :user_id, :users

		add_fk :messages, :sender_id, :users

		add_fk :wiki_pages, :course_id, :courses
		add_fk :wiki_pages, :user_id, :users

		add_fk :wiki_page_versions, :wiki_page_id, :wiki_pages
		add_fk :wiki_page_versions, :course_id, :courses
		add_fk :wiki_page_versions, :user_id, :users
	end

	def self.down
	end
end
