class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
			t.string :email, null: false
			t.string :pw_hash, null: false
      t.index :email, unique: true

      t.timestamps null: false
    end
  end
end
