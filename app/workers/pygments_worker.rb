class PygmentsWorker
  include Sidekiq::Worker
  
  def perform(user_id)
      user = User.find(user_id)
	  user_likes = user.score_games
	  reccommendation = user.reccommendation
	  reccommendation.update_attribute(:reccs, user_likes)
   	  # user.update_attribute(:reccs, user_likes)
	  # sign_in(user)
	  # flash[:success] = "Reccs Updated"
	  # redirect_to(user)
  end

end