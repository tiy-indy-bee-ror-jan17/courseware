class CourseInstructor < ActiveRecord::Base

  belongs_to :course
  has_many :instructors,  foreign_key:  'instructor_id',
                          class_name:   'User'

end
