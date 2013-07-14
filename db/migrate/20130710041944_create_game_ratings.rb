class CreateGameRatings < ActiveRecord::Migration
  def change
    create_table :game_ratings do |t|
      t.integer :rating
      t.integer :user_id
      t.integer :game_id

      t.timestamps
    end
  end
end
