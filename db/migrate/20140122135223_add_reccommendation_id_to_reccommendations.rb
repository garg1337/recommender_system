class AddReccommendationIdToReccommendations < ActiveRecord::Migration
  def change
    add_column :reccommendations, :reccommendation_id, :integer
  end
end
