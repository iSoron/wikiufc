class CreateMessages < ActiveRecord::Migration
	def self.up
		create_table :messages do |t|
			t.column :title,     :string
			t.column :body,      :text,      :null => false
			t.column :timestamp, :timestamp, :null => false
			t.column :message_type, :int, :null => false
			#t.column :sender_id,    :int, :null => false
			t.column :receiver_id,  :int
		end
	end

	def self.down
		drop_table :messages
	end
end
