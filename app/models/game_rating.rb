class GameRating < ActiveRecord::Base
  attr_accessible :game_id, :rating, :user_id
  belongs_to :user
  belongs_to :game

  validates :user_id, presence: true
  validates :game_id, presence: true
  validates :rating, presence: true 


end
