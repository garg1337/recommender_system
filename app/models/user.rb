 class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  has_many :game_ratings, dependent: :destroy
  has_many :games, :through => :game_ratings
  before_save { email.downcase! }
  before_save :create_remember_token


  validates :name, presence: true, length: { maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :password, presence: true, length: { minimum: 6}
  validates :password_confirmation, presence: true
  after_validation {self.errors.messages.delete(:password_digest)}



    def normalize_user_game_ratings
      game_ratings.sort!{|a,b| a.rating <=> b.rating}
      min_rating = game_ratings.first.rating
      max_rating = game_ratings.last.rating
      min_scale = -5.0;
      max_scale = 5.0;

      normalized_game_ratings = Hash.new

      if(game_ratings.size == 1)
        game_rating = game_ratings.first
        normalized_game_ratings[game_rating.game.title] = [game_rating.game_id, 5]
        return normalized_game_ratings
      end

      game_ratings.each do |game_rating|
        multiplier = ((game_rating.rating-min_rating)*(max_scale - min_scale))
        addition = multiplier / (max_rating - min_rating)
        normalized_game_ratings[game_rating.game.title] = [game_rating.game_id, min_scale +  addition]
      end

      return normalized_game_ratings
    end



    def generate_publisher_scoring_hash(normalized_ratings)
      publisher_scoring_hash = Hash.new
      normalized_ratings.each do |key, value|
        game = Game.find(value[0])
        publisher = game.publisher
        if publisher != nil
          if publisher_scoring_hash.has_key?(publisher)
            publisher_scoring_hash[publisher] += value[1]
          else
            publisher_scoring_hash[publisher] = value[1]
          end
        end
      end

      return publisher_scoring_hash
    end

    def generate_developer_scoring_hash(normalized_ratings)
      developer_scoring_hash = Hash.new
      normalized_ratings.each do |key, value|
        game = Game.find(value[0])
        developer = game.developer
        if developer != nil
          if developer_scoring_hash.has_key?(developer)
            developer_scoring_hash[developer] += value[1]
          else
            developer_scoring_hash[developer] = value[1]
          end
        end
      end

      return developer_scoring_hash
    end


    def generate_genre_scoring_hash(normalized_ratings)
      genre_scoring_hash = Hash.new
      normalized_ratings.each do |key,value|
        game = Game.find(value[0])
        genres = game.genres

        if !genres.empty?
          genres.each do |genre|
            if genre_scoring_hash.has_key?(genre)
              genre_scoring_hash[genre] += value[1]
            else
              genre_scoring_hash[genre] = value[1]
            end
          end
        end
      end
      return genre_scoring_hash
    end


    def score_games
      normalized_scores = normalize_user_game_ratings
      publisher_scores = generate_publisher_scoring_hash(normalized_scores)
      developer_scores = generate_developer_scoring_hash(normalized_scores)
      genre_scores = generate_genre_scoring_hash(normalized_scores)

      game_score_hash = Hash.new
      games_all = Game.all

      games_all.each do |game|

        if games.include?(game)
          next
        end

        publisher = game.publisher
        developer = game.developer
        genres = game.genres


        if !game_score_hash.has_key?(game.id)
          game_score_hash[game.id] = 0
        end


        if publisher != nil && publisher_scores.has_key?(publisher)
          game_score_hash[game.id] += publisher_scores[publisher]
        end

        if developer != nil && developer_scores.has_key?(developer)
          game_score_hash[game.id] += developer_scores[developer]
        end

        if !(genres.empty?)
          genres.each do |genre|
            if genre_scores.has_key?(genre)
              game_score_hash[game.id] += genre_scores[genre]
            end
          end
        end
      end

      game_scores = game_score_hash.sort_by {|k, v| v}

      game_scores = game_scores[game_scores.length-11...game_scores.length-1]

      game_scores.each do |game_score|
        metacritic_addition = (Game.find(game_score[0]).metacritic_rating.to_i) / 100.0
        game_score[1] += metacritic_addition
      end

      game_scores.sort!{|a,b| a[1] <=> b[1]}



      game_scores.each do |game_score|
        title = Game.find(game_score[0]).title
        value = game_score[1]
      end

      return game_scores
    end


    def user_similarity(other)
      sum = -1;
      other_normalized_ratings = other.normalize_user_game_ratings
      this_normalized_ratings = normalize_user_game_ratings

      other_normalized_ratings.each do |key, value|
        other_user_rating = value[1]
        this_user_rating_pair = this_normalized_ratings[key]
        if(!this_user_rating_pair.nil?)
          this_user_rating = this_user_rating_pair[1]
          diff = (this_user_rating - other_user_rating)
          diff = diff * diff

          if(sum == -1)
            sum = 0.0
          end

          sum = sum + diff
        end
      end

      if(sum == -1)
        return 0
      end
      euclidean_distance = Math.sqrt(sum)
      return (1.0)/(1.0 + euclidean_distance)
    end

    def user_similarities
      users = User.all
      sim_hash = Hash.new
      users.each do |other_user|
        if(other_user.id != id )
          similarity = user_similarity(other_user)
          if(similarity != 0)
            sim_hash[other_user.id] = similarity
          end
        end
      end

      return sim_hash
    end

    def sim_score_games
      similarities = user_similarities
      user_ratings = normalize_user_game_ratings
      similarity_score_hash = Hash.new

      similarities.each do |key,value|
        sim_score = value
        other_user = User.find_by_id(key)
        other_user_game_ratings = other_user.normalize_user_game_ratings
        other_user_game_ratings.each do |key, value|
          other_user_rating = value[1]
          this_user_rating_pair = user_ratings[key]
          if(this_user_rating_pair.nil?)
            unrated_score = sim_score * other_user_rating
            if(!similarity_score_hash.has_key?(value[0]))
              similarity_score_hash[value[0]] = 0
            end
            similarity_score_hash[value[0]] += unrated_score
          end
        end
      end



      similarity_scores = similarity_score_hash.sort_by {|k, v| v}

      puts(similarity_scores.length)


      if(similarity_scores.length > 10)
        puts("more than ten")
        similarity_scores = similarity_scores[similarity_scores.length-10...similarity_scores.length-1]
      end

      similarity_scores.sort!{|a,b| a[1] <=> b[1]}
      similarity_scores.each do |similarity_score|
        title = Game.find(similarity_score[0]).title
        value = similarity_score[1]
      end

      return similarity_scores

    end


    # def user_similarity(other)
    #   other_games = other.games
    #   sum = -1;

    #   other_games.each do |other_game|
    #     game_this_user = games.find_by_title(other_game.title)
    #     if(!game_this_user.nil?)
    #       this_user_rating = game_ratings.find_by_game_id(game_this_user.id).rating
    #       other_user_rating = other.game_ratings.find_by_game_id(other_game.id).rating
    #       diff = this_user_rating - other_user_rating
    #       diff = diff * diff

    #       if(sum == -1)
    #         sum = 0.0
    #       end

    #       sum = sum + diff

    #     end
    #   end


    #   if(sum == -1)
    #     return 0
    #   end

    #   euclidean_distance = Math.sqrt(sum)
    #   return euclidean_distance
    # end

























































  private
  	def create_remember_token
  		self.remember_token = SecureRandom.urlsafe_base64
  	end
  end



        

      # publisher_scores.each do |key,value|
      #   games_with_matching_publisher = Game.where(:publisher => key)
      #   if games_with_matching_publisher.empty?
      #     return "FUUUCK"
      #   end

      #   games_with_matching_publisher.each do |publisher_game|
      #     if game_score_hash.has_key?(publisher_game.id)
      #       game_score_hash[publisher_game.id] += value
      #     else
      #       game_score_hash[publisher_game.id] = value
      #     end
      #   end
      # end

      # developer_scores.each do |key,value|
      #   games_with_matching_developer = Game.where(:developer => key)
      #   if games_with_matching_developer.empty?
      #     return "FUUUCK"
      #   end

      #   games_with_matching_developer.each do |developer_game|
      #     if game_score_hash.has_key?(developer_game.id)
      #       game_score_hash[developer_game.id] += value
      #     else
      #       game_score_hash[developer_game.id] = value
      #     end
      #   end
      # end