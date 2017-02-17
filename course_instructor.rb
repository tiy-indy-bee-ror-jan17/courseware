class CourseInstructor < ActiveRecord::Base

  belongs_to :course
  ##belongs_to :instructor_id ##associate w/ users

end
