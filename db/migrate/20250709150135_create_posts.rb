class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.decimal :views
      t.string :tags
      t.vector :embedding, limit: 768

      t.timestamps
    end
  end
end
