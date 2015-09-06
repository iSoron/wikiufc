class RemoveUnversionedField < ActiveRecord::Migration
  def up
    remove_column :wiki_page_versions, :position
  end

  def down
  end
end
