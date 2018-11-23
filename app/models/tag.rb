class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :tasks, through: :taggings

  validates :title, presence: true, uniqueness: true

  scope :by_title, -> { order('title') }
  scope :partial_match, lambda { |term|
    term.nil? ? nil : where(['title LIKE ?', "%#{term}%"])
  }
end
