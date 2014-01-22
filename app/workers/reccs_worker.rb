class ReccsWorker
  include SuckerPunch::Job

  def perform(user_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
	  user_likes = user.score_games
	  reccommendation = user.reccommendation
	  reccommendation.update_attribute(:reccs, user_likes)
    end
  end
end