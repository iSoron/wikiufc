class LinkUserCourse < ActiveRecord::Migration
  def self.up
	# Relacionamento
	create_table :courses_users, :id => false do |t|		
	 t.column :user_id, :integer
	 t.column :course_id, :integer
	end
  end

  def self.down
	drop_table :courses_users
  end
end
