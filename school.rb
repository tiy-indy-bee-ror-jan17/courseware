class School < ActiveRecord::Base

  validates :name, presence: true

  has_many :terms
  has_many :courses, through: :terms
  has_many :course_students, through: :courses

  default_scope { order('name') }

end
