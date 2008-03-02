class DefaultPrefColor < ActiveRecord::Migration
  def self.up
	change_column :users, :pref_color, :integer, :default => 6
  end

  def self.down
	change_column :users, :pref_color, :integer
  end
end
