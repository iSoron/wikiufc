class MessageInheritance < ActiveRecord::Migration
	def self.up

		add_column :messages, :type, :string
	
		Message.find(:all).each do |m|
			case m.message_type
				when -1: m[:type] = "UserShoutboxMessage"
				when  0: m[:type] = "CourseShoutboxMessage"
				when  3: m[:type] = "News"
				else m[:type] = "Message"
			end
			m.save!
		end

		remove_column :messages, :message_type

	end

	def self.down
		add_column :messages, :message_type, :integer
		remove_column :messages, :type
	end
end
