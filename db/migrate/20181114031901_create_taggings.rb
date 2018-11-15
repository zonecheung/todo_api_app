class CreateTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :taggings do |t|
    	t.references :tag
    	t.references :task
      t.timestamps
    end
  end
end
