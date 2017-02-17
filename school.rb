class School < ActiveRecord::Base

  has_many :terms
  has_many :courses, through: :terms
  has_many :course_students, through: :courses

  default_scope { order('name') }

end
