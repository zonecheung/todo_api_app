class Tag < ApplicationRecord
	has_many :taggings, dependent: :destroy
	has_many :tasks, through: :taggings

	validates :title, presence: true, uniqueness: true
end
