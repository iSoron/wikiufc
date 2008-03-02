class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
        t.column :title,       :string,  :null => false
        t.column :date,        :date,    :null => false
        t.column :time,        :time,    :null => false
        t.column :created_by,  :integer, :null => false
        t.column :course_id,   :integer, :null => false, :default => 0
        t.column :description, :text
    end
  end

  def self.down
    drop_table :events
  end
end
