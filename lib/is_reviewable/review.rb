# coding: utf-8

module IsReviewable
  class Review < ::ActiveRecord::Base

    ASSOCIATIVE_FIELDS = [
        :reviewable_id,
        :reviewable_type,
        :reviewer_id,
        :reviewer_type,
        :ip
      ].freeze
    CONTENT_FIELDS = [
        :rating,
        :body
      ].freeze

    # Associations.
    belongs_to :reviewable, :polymorphic => true
    belongs_to :reviewer,   :polymorphic => true

    # Aliases.
    alias :object :reviewable
    alias :owner  :reviewer

    # Named scopes: Order.
    scope :in_order,            lambda {order 'reviews.created_at ASC'}
    scope :most_recent,         lambda {order 'reviews.created_at DESC'}
    scope :lowest_rating,       lambda {order 'reviews.rating ASC'}
    scope :highest_rating,      lambda {order 'reviews.rating DESC'}

    # Named scopes: Filters.
    scope :since,               lambda { |created_at_datetime|  { :conditions => ['reviews.created_at >= ?', created_at_datetime]} }
    scope :recent,              lambda { |arg|
                                        if [::ActiveSupport::TimeWithZone, ::DateTime].any? { |c| arg.is_a?(c) }
                                          {:conditions => ['reviews.created_at >= ?', arg]}
                                        else
                                          {:limit => arg.to_i}
                                        end
                                      }
    scope :between_dates,       lambda { |from_date, to_date|     {:conditions => {:created_at => (from_date..to_date)}} }
    scope :with_rating,         lambda { |rating_value_or_range|  {:conditions => {:rating => rating_value_or_range}} }
    scope :with_a_rating,       lambda { where('reviews.rating IS NOT NULL') }
    scope :without_a_rating,    lambda { where('reviews.rating IS NULL') }
    scope :with_a_body,         lambda { where('reviews.body IS NOT NULL AND LENGTH(reviews.body) > 0') }
    scope :without_a_body,      lambda { where('reviews.body IS NULL OR LENGTH(reviews.body) = 0') }
    scope :complete,            lambda { where('reviews.rating IS NOT NULL AND reviews.body IS NOT NULL AND LENGTH(reviews.body) > 0') }
    scope :of_reviewable_type,  lambda { |type|       {:conditions => Support.polymorphic_conditions_for(type, :reviewable, :type)} }
    scope :by_reviewer_type,    lambda { |type|       {:conditions => Support.polymorphic_conditions_for(type, :reviewer, :type)} }
    scope :on,                  lambda { |reviewable| {:conditions => Support.polymorphic_conditions_for(reviewable, :reviewable)} }
    scope :by,                  lambda { |reviewer|   {:conditions => Support.polymorphic_conditions_for(reviewer, :reviewer)} }

  end
end
