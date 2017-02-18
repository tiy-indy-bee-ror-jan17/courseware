class CourseInstructor < ActiveRecord::Base

  belongs_to :course
  belongs_to :user, class_name: "CourseInstructor", foreign_key: "instructor_id"
  belongs_to :instructor, class_name: "User"

end
