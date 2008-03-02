class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
    	t.column :file_name, :string
    	t.column :content_type, :string
    	t.column :last_modified, :datetime
    	t.column :description, :text
    	t.column :size, :int
    end
  end

  def self.down
    drop_table :attachments
  end
end
