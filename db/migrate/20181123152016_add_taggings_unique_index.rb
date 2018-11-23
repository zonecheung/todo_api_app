class AddTaggingsUniqueIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :taggings, [:task_id, :tag_id], unique: true
  end
end
