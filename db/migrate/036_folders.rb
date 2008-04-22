class Folders < ActiveRecord::Migration
	def self.up
		add_column :attachments, :path, :string
	end

	def self.down
		remove_column :attachments, :path
	end
end
