class CleanupDb < ActiveRecord::Migration
	def self.up
		change_column :attachments, :file_name, :string, :null => false
		
		change_column :courses, :description, :text, :null => true

		change_column :users, :login, :string, :null => false
		change_column :users, :hashed_password, :string, :null => false
		change_column :users, :email, :string, :null => false
		change_column :users, :salt, :string, :null => false
		change_column :users, :pref_color, :integer, :null => false

		change_column :wiki_pages, :course_id, :integer, :null => false
		change_column :wiki_pages, :user_id, :integer, :null => false
		change_column :wiki_pages, :description, :string, :null => false
		change_column :wiki_pages, :title, :string, :null => false
		change_column :wiki_pages, :position, :integer, :null => true
		
		drop_table :forum_forums                             
		drop_table :forum_logged_exceptions                  
		drop_table :forum_moderatorships                     
		drop_table :forum_monitorships                       
		drop_table :forum_open_id_authentication_associations
		drop_table :forum_open_id_authentication_nonces      
		drop_table :forum_open_id_authentication_settings    
		drop_table :forum_posts                              
		drop_table :forum_schema_info                        
		drop_table :forum_sessions                           
		drop_table :forum_topics                             
		drop_table :forum_users
	end

	def self.down
	end
end
