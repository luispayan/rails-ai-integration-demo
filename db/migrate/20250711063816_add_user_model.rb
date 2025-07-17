class AddUserModel < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :gender
      t.integer :age
      t.string :country
      t.string :state
      t.date :signup_date

      t.timestamps
    end
  end
end
