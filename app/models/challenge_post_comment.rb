# frozen_string_literal: true

class ChallengePostComment < ApplicationRecord
  include Recoverable

  belongs_to :user
  belongs_to :challenge_post
  belongs_to :parent, class_name: 'ChallengePostComment'

  has_many :children,
           class_name: 'ChallengePostComment',
           foreign_key: 'parent_id'

  validates :user, :challenge_post, :body, presence: true

  validate :parent_challenge_post_matches_challenge_post

  def parent_challenge_post_matches_challenge_post
    return unless parent
    return if parent.challenge_post == challenge_post

    errors.add(:parent, "parent's challenge_post must match")
  end
end