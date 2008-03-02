class UserDisplayName < ActiveRecord::Migration
  def self.up
    add_column :users, :display_name, :string
    add_column :users, :description, :text
    add_column :users, :last_seen, :datetime

    User.find(:all).each do |user|
      user.display_name = user.login
      user.last_seen = Time.now
      user.save!
    end

    change_column :users, :display_name, :string, :null => false
    change_column :users, :last_seen, :datetime, :null => false
  end

  def self.down
    remove_column :users, :display_name
    remove_column :users, :description
    remove_column :users, :last_seen
  end
end
