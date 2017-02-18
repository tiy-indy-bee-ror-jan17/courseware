class Reading < ActiveRecord::Base

  belongs_to :lesson
  has_many :courses, through: :lessons
  url_regx = /\Ahttps?:\/\//
# Validate that Readings must have an order_number, a lesson_id, and a url.
  validates   :order_number, presence: true
  validates   :lesson_id, presence: true
  validates   :url, presence: true,
                format: {with: url_regx}

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
