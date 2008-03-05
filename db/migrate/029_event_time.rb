class EventTime < ActiveRecord::Migration
  def self.up
    remove_column :events, :date
	remove_column :events, :time
	add_column :events, :time, :datetime, :null => false, :default => Time.now
  end

  def self.down
  end
end
