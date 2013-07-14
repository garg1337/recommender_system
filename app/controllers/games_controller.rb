class GamesController < ApplicationController

	before_filter :signed_in_user, only:[:show]
	def index

	end

	def show
		@game = Game.find(params[:id])
		if @game.game_ratings.find_by_user_id(current_user.id).nil?
			@game_rating = current_user.game_ratings.build if signed_in?
		else
			@game_rating = current_user.game_ratings.find_by_game_id(@game.id)
		end
	end
end
