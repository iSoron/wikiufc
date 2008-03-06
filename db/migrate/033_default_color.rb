class DefaultColor < ActiveRecord::Migration
	def self.up
		change_column :users, :pref_color, :integer, :default => 0, :null => false
		User.find(:all).each do |user|
			user.update_attribute(:pref_color, 0)
		end
	end

	def self.down
		change_column :users, :pref_color, :integer, :default => 6, :null => false
	end
end
