class AddPrefColor < ActiveRecord::Migration
  def self.up
	add_column :users, :pref_color, :integer
  end

  def self.down
	remove_column :users, :pref_color
  end
end
