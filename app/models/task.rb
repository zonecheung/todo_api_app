class Task < ApplicationRecord
	has_many :taggings, dependent: :destroy
	has_many :tags, through: :taggings

	attr_writer :tags

	validates :title, presence: true

	after_save :update_tags

	private

	def update_tags
	  # Not sure if we need to use acts_as_taggable gem for this, it's overkill.
		return if @tags.nil?
		current_tags = @tags.reject(&:blank?).map(&:strip)
		remove_old_taggings(current_tags)
		add_new_taggings(current_tags)
	end

	def remove_old_taggings(current_tags)
		new_tag_ids = self.tags.where(title: current_tags).pluck(:id) + [0]
		# Remove taggings if the tag_id is not available.
		self.taggings.where(['tag_id NOT IN (?)', new_tag_ids]).destroy_all
	end

	def add_new_taggings(current_tags)
		current_tags.each do |current_tag|
			tag = Tag.where(title: current_tag).first_or_create
			self.taggings.where(tag_id: tag.id).first_or_create
		end
	end
end
