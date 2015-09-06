class AddNotNull < ActiveRecord::Migration
  def up
    change_column_null :courses, :period, false, "0000.0"

    change_column_null :wiki_pages, :canonical_title, false, ""
    change_column_null :wiki_pages, :position, false, 0
    change_column_null :wiki_pages, :created_at, false, Time.now
    change_column_null :wiki_pages, :updated_at, false, Time.now

    change_column_null :wiki_page_versions, :wiki_page_id, false, WikiPage.first.id
    change_column_null :wiki_page_versions, :version, false, 1
    change_column_null :wiki_page_versions, :course_id, false, Course.first.id
    change_column_null :wiki_page_versions, :user_id, false, User.first.id
    change_column_null :wiki_page_versions, :description, false, ''
    change_column_null :wiki_page_versions, :title, false, ''
    change_column_null :wiki_page_versions, :content, false, ''
    change_column_null :wiki_page_versions, :created_at, false, Time.now
    change_column_null :wiki_page_versions, :updated_at, false, Time.now
    change_column_null :wiki_page_versions, :position, false, 0

    WikiPage.with_deleted.where(canonical_title: '').each do |wp|
      wp.update_attribute(:canonical_title, wp.title.pretty_url)
    end

  end

  def down
    change_column_null :courses, :period, true

    change_column_null :wiki_pages, :canonical_title, true
    change_column_null :wiki_pages, :position, true
    change_column_null :wiki_pages, :created_at, true
    change_column_null :wiki_pages, :updated_at, true

    change_column_null :wiki_page_versions, :created_at, true
    change_column_null :wiki_page_versions, :updated_at, true
  end
end
