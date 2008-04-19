class ResetPassword < ActiveRecord::Migration
	def self.up
		add_column :users, :password_reset_key, :string
	end

	def self.down
		remove_column :users, :password_reset_key
	end
end
