class Reading < ActiveRecord::Base

  belongs_to :lesson, dependent: :destroy
  has_many :courses, through: :lessons

  validates :order_number, presence: true
  validates :lesson_id, presence: true
  validates :url,
            presence: true,
            format: { with: /https?:\/\/[\S]+/,
                      message: "Must be a valid url" }

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
