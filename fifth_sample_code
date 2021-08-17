class Review < ApplicationRecord
  belongs_to :user
  belongs_to :coach

  def self.review_average(rating)
    r_coach_ids = []
    coach_ids = self.pluck(:coach_id).uniq
    coach_ids.each do |coach_id|
      av_coach_ratings = self.average_coach_review(coach_id)
      r_coach_ids << coach_id if av_coach_ratings == rating.to_i
    end
    return r_coach_ids
  end

  def self.average_coach_review(coach_id)
    coach_ratings = self.where(coach_id: coach_id).pluck(:rating)
    sorted_ratings = Hash[coach_ratings.group_by{|i| i }.map{|k,v| [k,v.size]}]
    1.upto(5) do |i|
      sorted_ratings[i] = 0 unless sorted_ratings.has_key?(i)
    end
    rating_sum = (sorted_ratings.map{|k,v| v}.sum)
    return av_coach_ratings = rating_sum.to_i > 0 ? (sorted_ratings.map{|k,v| k*v}.sum).to_i/rating_sum.to_i : 'No Review'
  end
end
