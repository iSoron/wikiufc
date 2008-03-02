class AddWikiVersionDescription < ActiveRecord::Migration
  def self.up
	add_column :wiki_versions, :description, :text
  end

  def self.down
  	remove_column :wiki_versions, :description
  end
end
