class CourseInstructor < ActiveRecord::Base
  belongs_to :course
  if :primary
    validates :primary, uniqueness: { scope: :course_id, message: "instructor can only exist once per course"}
  end
end
