class CreateForum < ActiveRecord::Migration
	def self.up
		create_table "forum_forums", :force => true do |t|
			t.string  "name"
			t.string  "description"
			t.integer "topics_count",     :default => 0
			t.integer "posts_count",      :default => 0
			t.integer "position"
			t.text    "description_html"
		end

		create_table "forum_logged_exceptions", :force => true do |t|
			t.string   "exception_class"
			t.string   "controller_name"
			t.string   "action_name"
			t.string   "message"
			t.text     "backtrace"
			t.text     "environment"
			t.text     "request"
			t.datetime "created_at"
		end

		create_table "forum_moderatorships", :force => true do |t|
			t.integer "forum_id"
			t.integer "user_id"
		end

		add_index "forum_moderatorships", ["forum_id"], :name => "index_moderatorships_on_forum_id"

		create_table "forum_monitorships", :force => true do |t|
			t.integer "topic_id"
			t.integer "user_id"
			t.boolean "active",   :default => true
		end

		create_table "forum_open_id_authentication_associations", :force => true do |t|
			t.binary  "server_url"
			t.string  "handle"
			t.binary  "secret"
			t.integer "issued"
			t.integer "lifetime"
			t.string  "assoc_type"
		end

		create_table "forum_open_id_authentication_nonces", :force => true do |t|
			t.string  "nonce"
			t.integer "created"
		end

		create_table "forum_open_id_authentication_settings", :force => true do |t|
			t.string "setting"
			t.binary "value"
		end

		create_table "forum_posts", :force => true do |t|
			t.integer  "user_id"
			t.integer  "topic_id"
			t.text     "body"
			t.datetime "created_at"
			t.datetime "updated_at"
			t.integer  "forum_id"
			t.text     "body_html"
		end

		add_index "forum_posts", ["topic_id", "created_at"], :name => "index_posts_on_topic_id"
		add_index "forum_posts", ["user_id", "created_at"], :name => "index_posts_on_user_id"
		add_index "forum_posts", ["forum_id", "created_at"], :name => "index_posts_on_forum_id"

		create_table "forum_schema_info", :id => false, :force => true do |t|
			t.integer "version"
		end

		create_table "forum_sessions", :force => true do |t|
			t.string   "session_id"
			t.text     "data"
			t.datetime "updated_at"
			t.integer  "user_id"
		end

		add_index "forum_sessions", ["session_id"], :name => "sessions_session_id_index"

		create_table "forum_topics", :force => true do |t|
			t.integer  "forum_id"
			t.integer  "user_id"
			t.string   "title"
			t.datetime "created_at"
			t.datetime "updated_at"
			t.integer  "hits",         :default => 0
			t.integer  "sticky",       :default => 0
			t.integer  "posts_count",  :default => 0
			t.datetime "replied_at"
			t.boolean  "locked",       :default => false
			t.integer  "replied_by"
			t.integer  "last_post_id"
		end

		add_index "forum_topics", ["forum_id", "replied_at"], :name => "index_topics_on_forum_id_and_replied_at"
		add_index "forum_topics", ["forum_id", "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
		add_index "forum_topics", ["forum_id"], :name => "index_topics_on_forum_id"

		create_table "forum_users", :force => true do |t|
			t.string   "login"
			t.string   "email"
			t.string   "password_hash"
			t.datetime "created_at"
			t.datetime "last_login_at"
			t.boolean  "admin"
			t.integer  "posts_count",          :default => 0
			t.datetime "last_seen_at"
			t.string   "display_name"
			t.datetime "updated_at"
			t.string   "website"
			t.string   "login_key"
			t.datetime "login_key_expires_at"
			t.boolean  "activated",            :default => false
			t.string   "bio"
			t.text     "bio_html"
			t.string   "openid_url"
		end

		add_index "forum_users", ["posts_count"], :name => "index_users_on_posts_count"
		add_index "forum_users", ["last_seen_at"], :name => "index_users_on_last_seen_at"

		time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
		execute "insert into forum_users (id, login, email, created_at,"   + 
				"last_login_at, admin, display_name, updated_at, website," +
				"activated) select u.id, u.login, u.email, '#{time}',"     +
				"'#{time}', 1, u.name, '#{time}', '', 1 from users u"
	end

	def self.down
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
end
