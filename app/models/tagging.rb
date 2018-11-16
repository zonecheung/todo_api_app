class Tagging < ApplicationRecord
  belongs_to :task
  belongs_to :tag

  validates :tag_id, presence: true, uniqueness: { scope: :task_id }
end
