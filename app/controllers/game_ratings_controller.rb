class GameRatingsController < ApplicationController

  before_filter :signed_in_user

  def create
	@game_rating = current_user.game_ratings.build(params[:game_rating])
    if @game_rating.save
      flash[:success] = "Game Rating Created!"
      redirect_to Game.find(params[:game_rating][:game_id])
    else
      render 'static_pages/home'
    end
  end

  def destroy
    @game_rating = GameRating.find(params[:id])
    @game = Game.find(@game_rating.game_id)
    @game_rating.destroy
    flash[:success] ="Game Rating Removed"
    redirect_to @game
  end

  def update
  	@game_rating = GameRating.find(params[:id])
  	rating = params[:game_rating][:rating]

  	if 	@game_rating.update_attributes(:rating => rating)
  		flash[:success] = "Game Rating Updated!"
  		redirect_to Game.find(@game_rating.game_id)
    else
      render 'static_pages/home'
    end
  end

end