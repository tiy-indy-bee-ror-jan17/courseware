class Tag < ActiveRecord::Base

  belongs_to :taggable, polymorphic: true

  has_many :tags, as: :taggable

  validates :name, presence:true, uniqueness: true
  validates :taggable, presence: true

  validate :class_can_be_tagged

  def class_can_be_tagged
    allowed = %w(User Lesson Course Assignment Tag)
    return if allowed.include?(taggable_type)
    errors.add(:taggable_type, 'cannot be tagged')
  end

end
