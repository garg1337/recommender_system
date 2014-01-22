class Reccommendation < ActiveRecord::Base
  attr_accessible :reccs, :user_id
  serialize :reccs
  belongs_to :user
end
