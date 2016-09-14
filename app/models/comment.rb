class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true

  validates :locale, presence: true
  validates :locale, inclusion: { in: I18n.available_locales.map{|l| l.to_s},
    message: "%{value} is not a valid defined locale" }
  validates :visibility, presence: true
  validates :visibility, inclusion: { in: %w(my_public private),
    message: "%{value} must be either my_public or private" }

  scope :my_public, -> {where(visibility: 'public')}
  scope :private, -> {where(visibility: 'private')}

  def self.for_locale
    where(locale: I18n.locale).first
  end

  def public?
    visibility=='public'
  end

  def private?
    !public?
  end

end