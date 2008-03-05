class UserSecret < ActiveRecord::Migration
  def self.up
  	add_column :users, :secret, :string, :null => true
	User.find(:all).each do |user|
		user.update_attribute(:secret, User.random_string(32))
	end
	change_column :users, :secret, :string, :null => false
  end

  def self.down
  	remove_column :users, :secret
  end
end
