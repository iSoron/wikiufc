class Diff < ActiveRecord::Migration
	def self.up
  		add_column :wiki_versions, :root, :boolean, :default => true, :null => false
		add_column :wiki_pages, :diff_countdown, :integer, :default => 0, :null => false

		WikiVersion.find(:all).each do |version|
			version.update_attribute(:root, false) if version.cache_html == nil
		end
	end

	def self.down
		remove_column :wiki_versions, :root
		remove_column :wiki_pages, :diff_countdown
	end
end
