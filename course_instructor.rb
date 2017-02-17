class CourseInstructor < ActiveRecord::Base

  belongs_to :course
  belongs_to :user, class_name: "CourseInstructor", foreign_key: "instructor_id"
end
