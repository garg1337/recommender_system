class CreateReccommendations < ActiveRecord::Migration
  def change
    create_table :reccommendations do |t|
      t.integer :user_id
      t.text :reccs

      t.timestamps
    end
  end
end
