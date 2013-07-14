class Game < ActiveRecord::Base
  serialize :genres, Array
  attr_accessible :coop, :description, :developer, :esrb_rating, :genres, :image_url, :metacritic_rating, :platform, :players, :publisher, :release_date, :title
  has_many :game_ratings
  has_many :users, :through => :game_ratings
end
