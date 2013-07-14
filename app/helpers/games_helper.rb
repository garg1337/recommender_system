module GamesHelper

	def boxart_for(game)
		return image_tag(game.image_url, :size => "300x436", alt: game.title)
	end

	def platform_for(game)
		if game.platform == nil
			return "N/A"
		else
			return game.platform
		end
	end

	def release_date_for(game)
		if game.release_date == nil
			return "N/A"
		else
			return game.release_date
		end
	end

	def description_for(game)
		if game.description == nil
			return "N/A"
		else
			return game.description
		end
	end

	def genres_for(game)
		if game.genres.empty?
			return "N/A"
		else
			return (game.genres.to_s.gsub(/[\[\]]/, '')).gsub(/"/, '')
		end
	end

	def rating_for(game)
		if game.esrb_rating == nil
			return "N/A"
		else
			return game.esrb_rating
		end
	end

	def players_for(game)
		if game.players == nil
			return "N/A"
		else
			return game.players
		end
	end

	def developer_for(game)
		if game.developer == nil
			return "N/A"
		else
			return game.developer
		end
	end

	def publisher_for(game)
		if game.publisher == nil
			return "N/A"
		else
			return game.publisher
		end
	end

	def coop_for(game)
		if game.coop == nil
			return "No"
		else
			return game.coop
		end
	end

	def metacritic_for(game)
		if game.metacritic_rating == '0'
			return "N/A"
		else
			return "#{game.metacritic_rating}/100"
		end
	end

	def user_rating_for(game)
		rating_object = game.game_ratings.find_by_user_id(current_user.id)
		if rating_object != nil
			return "#{rating_object.rating}/10"
		else
			return "N/A"
		end
	end

end
