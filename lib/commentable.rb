require 'active_support/concern'

module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable
    has_many :public_comments, -> {where( visibility: 'public').order(:locale)}, as: :commentable, class_name: 'Comment'
    has_many :private_comments, -> {where( visibility: 'private').order(:locale)}, as: :commentable, class_name: 'Comment'
    accepts_nested_attributes_for :comments, :public_comments, :private_comments, reject_if: :filter_out_comments,
      allow_destroy: true
  end

  def filter_out_comments attributes
    attributes['comment'].blank?
  end

end