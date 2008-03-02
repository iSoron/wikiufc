class DropProfessors < ActiveRecord::Migration
	def self.up
		drop_table :professors
		drop_table :courses_professors
	end

	def self.down
		create_table :professors do |t|
			t.column :name, :string, :null => false
		end

		create_table :courses_professors, :id => false do |t|
			t.column :professor_id, :integer
			t.column :course_id, :integer
		end	
	end
end
