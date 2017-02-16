class Reading < ActiveRecord::Base

  belongs_to :lesson, dependent: :destroy
  has_and_belongs_to_many :courses

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
