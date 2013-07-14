require 'spec_helper'

describe GameRating do
  let(:user) { FactoryGirl.create(:user) }
  before { @rating = user.game_ratings.build(rating: 2, game_id: 3) }

  subject { @rating }


end
