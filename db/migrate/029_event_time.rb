class EventTime < ActiveRecord::Migration
  def self.up
    change_column :events, :date, :date, :null => true
	change_column :events, :time, :datetime
  end

  def self.down
  end
end
