class MoreVersioned < ActiveRecord::Migration
	def self.up
		# Noticias
		add_column :messages, :version, :int, :default => 1, :null => false
		remove_column :messages, :updated_at
		Message.create_versioned_table
		Message.find(:all).each { |m| m.save_version_on_create }

		# Eventos
		add_column :events, :version, :int, :default => 1, :null => false
		Event.create_versioned_table
		Event.find(:all).each { |e| e.save_version_on_create }

		# Log
		NewsLogEntry.find(:all).each { |l| l.update_attribute(:version, 1) }
		EventLogEntry.find(:all).each { |l| l.update_attribute(:version, 1) }

	end

	def self.down
		# Noticias
		remove_column :messages, :version
		add_column :messages, :updated_at, :datetime
		Message.drop_versioned_table

		# Eventos
		remove_column :events, :version
		Event.drop_versioned_table

		# Log
		NewsLogEntry.find(:all).each { |l| l.update_attribute(:version, nil) }
		EventLogEntry.find(:all).each { |l| l.update_attribute(:version, nil) }
	end
end
