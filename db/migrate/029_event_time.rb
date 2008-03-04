class EventTime < ActiveRecord::Migration
  def self.up
    change_column :events, :date, :date, :null => true
  end

  def self.down
  end
end
