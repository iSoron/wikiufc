class Cache < ActiveRecord::Migration
	# Remove a coluna de cache
	def self.up
		remove_column :wiki_versions, "cache_html"
	end

	def self.down
		add_column :wiki_versions, "cache_html", :text
	end
end
