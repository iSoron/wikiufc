class Canonical< ActiveRecord::Migration
	def self.up
		add_column :wiki_pages, :canonical_title, :string
		WikiPage.find(:all).each do |wiki|
			wiki.update_attribute(:canonical_title, wiki.title.pretty_url)
		end
	end

	def self.down
		remove_column :wiki_pages, :canonical_title
	end
end
