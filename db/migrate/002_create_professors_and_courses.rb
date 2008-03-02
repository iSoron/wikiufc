class CreateProfessorsAndCourses < ActiveRecord::Migration
	def self.up

		# Tabela de professores
		create_table :professors do |t|
			t.column :name, :string, :null => false
		end

		# Tabela de disciplinas
		create_table :courses do |t|
			t.column :short_name, :string, :null => false
			t.column :full_name, :string, :null => false
			t.column :description, :text, :null => false
		end

		# Relacionamento
		create_table :courses_professors, :id => false do |t|
			t.column :professor_id, :integer
			t.column :course_id, :integer
		end	

		# Adiciona o campo disciplina aos objetos do repositorio
		add_column :attachments, :course_id, :integer
	end

	def self.down
		drop_table :professors
		drop_table :courses
		drop_table :courses_professors
		remove_column :attachments, :course_id
	end
end
