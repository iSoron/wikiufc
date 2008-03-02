class WikiPageOrder < ActiveRecord::Migration
	def self.up
		add_column :wiki_pages, :position, :integer
		add_column :wiki_page_versions, :position, :integer
		Course.find(:all).each do |course|
			course.wiki_pages.each_with_index do |wp, i|
				wp.position = i+1
				wp.save!
			end
		end
	end

	def self.down
		remove_column :wiki_pages, :position
	end
end
