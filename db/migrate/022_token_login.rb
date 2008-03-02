class TokenLogin < ActiveRecord::Migration
	def self.up
		add_column :users, :login_key, :string

    	User.find(:all).each do |user|
    		user.login_key = Digest::SHA1.hexdigest(Time.now.to_s + user.password.to_s + rand(123456789).to_s).to_s
			user.save!
		end
	end

	def self.down
		remove_column :users, :login_key
	end
end
